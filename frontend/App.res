open Schema
open Reducer
open Belt
open Util
open Airtable

@react.component
let make = () => {
  let schema = buildSchema(SchemaDefinitionUser.allTables)
  let (state, dispatch) = React.useReducer(reducer, initialState)

  let searchQuery = state.searchString->trimLower
  let isSearching = searchQuery != ""
  let trackingRecords: array<skuOrderTrackingRecord> =
    schema.skuOrderTracking.hasTrackingNumbersView.useRecords([
      schema.skuOrderTracking.isReceivedField.sortAsc,
      schema.skuOrderTracking.shipDateField.sortDesc,
    ])->Array.keep(record => {
      //->Array.map(tracking => (tracking,tracking.skuOrders.useRecords([])))
      // keep everything if we don't have a search string, else get items that include the search query
      !isSearching || Js.String.includes(searchQuery, record.trackingNumber.read()->trimLower)
    })

  let loadAndWatch: array<airtableRawRecordQueryResult> => unit = arr =>
    arr->useMultipleQueries->useWatchable([`records`, `cellValues`])

  // descend 1 level down
  let mapTracking = fn => trackingRecords->Array.map(fn)
  let _ = mapTracking(tracking => tracking.skuOrders.rel.getRecordsQueryResult([])) |> loadAndWatch

  // descend 2 levels
  let flatMapSkuOrders = fn =>
    mapTracking(tracking =>
      tracking.skuOrders.rel.getRecords([])->Array.map(fn)
    ) |> Array.concatMany
  let _ =
    flatMapSkuOrders(skuOrder => [
      skuOrder.skuOrderSku.rel.getRecordQueryResult(),
      skuOrder.trackingRecord.rel.getRecordQueryResult(),
      skuOrder.skuOrderBoxDest.rel.getRecordQueryResult(),
      skuOrder.skuOrderBoxLines.rel.getRecordsQueryResult([]),
    ])
    |> Array.concatMany
    |> loadAndWatch

  // descend 3 levels
  let flatMapBoxDestination = fn =>
    flatMapSkuOrders(skuOrder =>
      skuOrder.skuOrderBoxDest.rel.getRecord()->Option.map(fn)
    )->Array.keepMap(identity)
  let boxSortParams = [schema.box.boxNumberOnlyField.sortDesc]
  let _ =
    flatMapBoxDestination(boxDest =>
      boxDest.boxes.rel.getRecordsQueryResult(boxSortParams)
    ) |> loadAndWatch

  // descend 4 levels
  let flatMapBox = fn =>
    flatMapBoxDestination(boxDest =>
      boxDest.boxes.rel.getRecords(boxSortParams)->Array.map(fn)
    ) |> Array.concatMany
  let _ = flatMapBox(box => box.boxLines.rel.getRecordsQueryResult([])) |> loadAndWatch

  // descend 5 levels
  let flatMapBoxLine = fn =>
    flatMapBox(box => box.boxLines.rel.getRecords([])->Array.map(fn)) |> Array.concatMany
  let _ =
    flatMapBoxLine(ln => [
      ln.boxLineSku.rel.getRecordQueryResult(),
      ln.boxRecord.rel.getRecordQueryResult(),
    ])
    |> Array.concatMany
    |> loadAndWatch

  let skuOrderRecords: array<skuOrderRecord> =
    trackingRecords->Array.length == 1
    // we don't wanna show shit if we haven't narrowed the results
    // can only show sku orders for received tracking numbers
      ? trackingRecords
        ->Array.keep(sot => sot.isReceived.read())
        ->Array.map(sot => sot.skuOrders.rel.getRecords([]))
        ->Array.concatMany
      : []

  let messageAboutSkuOrderResults = switch (
    trackingRecords->Array.length,
    trackingRecords->Array.get(0)->Option.map(sot => sot.isReceived.read()),
  ) {
  | (0, _) => `Change your search query to find a tracking record`
  | (n, _) when n > 1 => `Focus on a single tracking record to display SKUs`
  | (
      1,
      Some(true),
    ) => `No skus are listed for this tracking number. If this is an error, get in touch! :)`
  | (1, Some(false)) => `Receive this tracking number to see SKUs`
  | _ => `Err`
  }

  //Js.Console.log(skuOrderRecords)

  <div style={ReactDOM.Style.make(~padding="8px", ())}>
    <SearchBox state dispatch />
    <div style={ReactDOM.Style.make(~marginBottom="26px", ())} />
    <SkuOrderTrackingResults state dispatch schema trackingRecords />
    <div style={ReactDOM.Style.make(~marginBottom="26px", ())} />
    {skuOrderRecords->Array.length > 0
      ? <SkuOrderResults state dispatch schema skuOrderRecords />
      : <p style={ReactDOM.Style.make(~fontSize="16px", ~color="red", ())}>
          {messageAboutSkuOrderResults->s}
        </p>}
  </div>
}
