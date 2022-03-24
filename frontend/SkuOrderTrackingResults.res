open Belt
open Util
open AirtableUI
open Schema
open SkuOrderTrackingDialog
open PipelineDialog
open Reducer

@react.component
let make = (
  ~state: Reducer.state,
  ~dispatch,
  ~schema: Schema.schema,
  ~trackingRecords: array<skuOrderTrackingRecord>,
) => {
  // so this is a hook, remember
  let focusedTrackingRecordOpt = schema.skuOrderTracking.rel.useRecordById(
    state.focusOnTrackingRecordId,
  )
  <div>
    <Heading> {React.string("Tracking Numbers")} </Heading>
    <Table
      rowId={record => record.id}
      elements=trackingRecords
      columnDefs=[
        {
          header: `Received?`,
          accessor: record => {
            <span> {s(record.isReceived.read() ? `✅` : `❌`)} </span>
          },
          tdStyle: ReactDOM.Style.make(~width="5%", ~textAlign="center", ~fontSize="1.8em", ()),
        },
        {
          header: `Tracking Number`,
          accessor: record => {
            open Js.String

            let lnk = record.trackingLink.read()->Js.String.trim
            let shw = lnk->length > 10

            <span>
              {record.trackingNumber.render()}
              {shw
                ? <a
                    href={lnk} target="_blank" style={ReactDOM.Style.make(~fontStyle="italic", ())}>
                    {`track package`->s}
                  </a>
                : React.null}
            </span>
          },
          tdStyle: ReactDOM.Style.make(~width="15%", ()),
        },
        {
          header: `Ship Date`,
          accessor: record => record.shipDate.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `JoCo Notes`,
          accessor: record => record.jocoNotes.render(),
          tdStyle: ReactDOM.Style.make(~width="35%", ()),
        },
        {
          header: `Warehouse Notes`,
          accessor: record => record.warehouseNotes.render(),
          tdStyle: ReactDOM.Style.make(~width="35%", ()),
        },
        {
          header: `🔎 🕵️ 🔬 🔍`,
          accessor: record =>
            if trackingRecords->Array.length > 1 {
              <SecondaryActionButton
                onClick={() => dispatch(UpdateSearchString(record.trackingNumber.read()))}>
                {`Focus`->s}
              </SecondaryActionButton>
            } else {
              <CancelButton onClick={() => dispatch(UpdateSearchString(""))}>
                {`Clear Focus`->s}
              </CancelButton>
            },
          tdStyle: ReactDOM.Style.make(~textAlign="center", ()),
        },
        {
          header: `Action`,
          accessor: record => parseRecordState(schema, record, state, dispatch).activationButton,
          tdStyle: ReactDOM.Style.make(~textAlign="center", ()),
        },
      ]
    />
    {focusedTrackingRecordOpt->Option.mapWithDefault(React.null, record =>
      parseRecordState(schema, record, state, dispatch).dialog
    )}
  </div>
}
