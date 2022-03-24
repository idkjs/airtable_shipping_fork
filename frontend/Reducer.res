open Belt
open Schema
open SchemaDefinition
open Util
open SkuOrderBox
@@warning("-45")

type rec action =
  | UpdateSearchString(string)
  | FocusOnTrackingRecord(skuOrderTrackingRecord)
  | UnfocusTrackingRecord
  // maybe not used
  | BlindlyPromise(unit => Js.Promise.t<unit>)
  | UpdateWarehouseNotes(string)
  | FocusOnOrderRecord(skuOrderRecord)
  | UnfocusOrderRecord
  | UpdateSKUReceivedQty(option<int>)
  | UpdateReceivingNotes(string)
  | UpdateSKUSerial(string)
  | UpdateBoxSearchString(boxDestinationRecord, string)
  | ClearBoxSearchString(boxDestinationRecord)
  | UpdateQtyToBox(skuOrderRecord, potentialBox, int)
  | UpdateBoxNotes(skuOrderRecord, potentialBox, string)
  | UseBox(skuOrderRecord, potentialBox)
  | ClearBoxToUse
  | ShowPackedBoxes
  | ClearShowPackedBoxes
  | FocusOnSkuAttachments(skuRecord)
  | UnFocusOnSkuAttachments
  | SkuAttachmentsNextPage

and boxStuff = {name: string, qty: int, notes: string}

type state = {
  // search for tracking
  searchString: string,
  // tracking receive
  warehouseNotes: string,
  focusOnTrackingRecordId: recordId<skuOrderTrackingRecord>,
  focusOnSkuOrderRecordId: recordId<skuOrderRecord>,
  skuAttachments: (recordId<skuRecord>, int),
  skuQuantityReceived: option<int>,
  skuReceivingNotes: string,
  skuSerial: string,
  // box
  boxSearchString: Map.String.t<string>,
  boxStuffMap: Map.String.t<boxStuff>,
  boxToUseForPacking: option<boxStuff>,
  showPackedBoxes: bool,
}

let initialState: state = {
  searchString: "",
  warehouseNotes: "",
  focusOnTrackingRecordId: nullRecordId,
  focusOnSkuOrderRecordId: nullRecordId,
  skuAttachments: (nullRecordId, -1),
  skuQuantityReceived: None,
  skuReceivingNotes: "",
  skuSerial: "",
  boxSearchString: Map.String.empty,
  boxStuffMap: Map.String.empty,
  boxToUseForPacking: None,
  showPackedBoxes: false,
}

let rec reducer = (state, action) => {
  let rv = switch action {
  | UpdateSearchString(str) => {...state, searchString: str}
  | FocusOnTrackingRecord(skotr) => {...state, focusOnTrackingRecordId: skotr.id}
  | UnfocusTrackingRecord => {...state, focusOnTrackingRecordId: nullRecordId}
  | FocusOnOrderRecord(so) => {...state, focusOnSkuOrderRecordId: so.id}
  | UnfocusOrderRecord => {...state, focusOnSkuOrderRecordId: nullRecordId}
  | BlindlyPromise(fn) => {
      //execute
      let _ = fn()
      state
    }
  | UpdateWarehouseNotes(str) => {
      ...state,
      warehouseNotes: str,
    }
  | UpdateSKUReceivedQty(i) => {
      ...state,
      skuQuantityReceived: i,
    }
  | UpdateReceivingNotes(s) => {
      ...state,
      skuReceivingNotes: s,
    }
  | UpdateSKUSerial(s) => {
      ...state,
      skuSerial: s,
    }
  | UpdateBoxSearchString(bdr, s) => {
      ...state,
      boxSearchString: state.boxSearchString->Map.String.update(bdr.destName.read(), _ => Some(s)),
      boxToUseForPacking: None,
      showPackedBoxes: false,
    }
  | ClearBoxSearchString(bdr) => {
      ...state,
      boxSearchString: state.boxSearchString->Map.String.update(bdr.destName.read(), _ => Some("")),
      boxToUseForPacking: None,
      showPackedBoxes: false,
    }
  | UpdateQtyToBox(skor, pb, qty) => {
      ...state,
      boxStuffMap: mapBoxStuff(state, skor, pb, bs => {...bs, qty: qty})->first,
    }
  | UpdateBoxNotes(skor, pb, notes) => {
      ...state,
      boxStuffMap: mapBoxStuff(state, skor, pb, bs => {...bs, notes: notes})->first,
    }

  | UseBox(skor, pb) => {
      ...state,
      boxToUseForPacking: Some(mapBoxStuff(state, skor, pb, identity)->second),
    }
  | ClearBoxToUse => {
      ...state,
      boxToUseForPacking: None,
    }
  | ShowPackedBoxes => {
      ...state,
      showPackedBoxes: true,
    }
  | ClearShowPackedBoxes => {
      ...state,
      showPackedBoxes: false,
    }
  | FocusOnSkuAttachments(skuRecord) => {
      ...state,
      skuAttachments: (skuRecord.id, 0),
    }
  | UnFocusOnSkuAttachments => {
      ...state,
      skuAttachments: (nullRecordId, -1),
    }
  | SkuAttachmentsNextPage => {
      ...state,
      skuAttachments: (state.skuAttachments->first, state.skuAttachments->second + 1),
    }
  }
  Js.Console.log(rv)
  rv
}
and mapBoxStuff: (
  state,
  skuOrderRecord,
  potentialBox,
  boxStuff => boxStuff,
) => (Map.String.t<boxStuff>, boxStuff) = (state, skor, pb, mapFn) => {
  let k = `${skor.id}_${pb.name}`
  // make it all gettable
  let dict =
    state.boxStuffMap->Map.String.update(k, bsopt => Some(
      bsopt->Option.mapWithDefault(
        {name: pb.name, qty: pb.unboxedQty, notes: pb.notes}->mapFn,
        mapFn,
      ),
    ))

  (dict, dict->Map.String.getExn(k)->mapFn)
}

let onChangeHandler: (action => unit, string => action, 'event) => unit = (
  dispatch,
  makeaction,
  event,
) => ReactEvent.Form.target(event)["value"]->makeaction->dispatch

let multi: (action => unit, array<action>) => unit = (dispatch, actions) => {
  let _ = actions->Array.map(dispatch)
}

let getQtyToBox = (state, skor, pb) => {
  mapBoxStuff(state, skor, pb, identity)->second->(bs => bs.qty)
}
let getBoxNotes = (state, skor, pb) => {
  mapBoxStuff(state, skor, pb, identity)->second->(bs => bs.notes)
}
let getSearchString = (state, bdr) => {
  state.boxSearchString->Map.String.get(bdr.destName.read())->Option.getWithDefault("")
}
