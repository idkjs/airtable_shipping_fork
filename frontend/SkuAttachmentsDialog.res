open PipelineDialog
open Util
open Schema
open Belt
open Airtable

let skuImageAttachments: skuRecord => array<airtableAttachment> = sku =>
  sku.skuAttachments.read()->Array.map(att => att.contentType->Option.flatMap(ctstr =>
      // starts with image/ e.g. image/jpeg etc
      ctstr |> Js.String.startsWith(`image/`) ? Some(att) : None
    ))->Array.keepMap(identity)

let skuHasImages: skuRecord => bool = sku => sku->skuImageAttachments->Array.length > 0

@react.component
let make = (~dispatch: Reducer.action => unit, ~state: Reducer.state, ~sku: skuRecord) => {
  let atts = sku->skuImageAttachments
  let nAtts = atts->Array.length
  // guard to prevent against div 0 exception
  let imIdx = nAtts > 0 ? mod(state.skuAttachments->second, nAtts) : 0
  let showOpt = atts->Array.get(imIdx)

  <PipelineDialog
    header={`${sku.skuName.read()}: Image ${(imIdx + 1)->Int.toString} of ${nAtts->Int.toString}`}
    actionButtons={nAtts > 1
      ? [
          <PrimaryActionButton
            onClick={() => dispatch(SkuAttachmentsNextPage)}
            style={ReactDOM.Style.make(~fontSize="2em", ())}>
            {`⏭️`->s}
          </PrimaryActionButton>,
        ]
      : []}
    closeCancel={() => dispatch(UnFocusOnSkuAttachments)}>
    <div>
      {showOpt->Option.mapWithDefault(`No image to display`->s, toShow =>
        <img
          src={toShow.thumbnail.large->Option.mapWithDefault(toShow.url, lg => lg.thumbnailUrl)}
          style={ReactDOM.Style.make(~maxHeight="600px", ())}
        />
      )}
    </div>
    <VSpace px={22} />
  </PipelineDialog>
}
