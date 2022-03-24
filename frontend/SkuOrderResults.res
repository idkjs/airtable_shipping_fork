open Belt
open AirtableUI
open Schema
open SkuOrderDialogState
open SkuAttachmentsDialog
open Util

@react.component
let make = (
  ~state: Reducer.state,
  ~dispatch,
  ~schema: Schema.schema,
  ~skuOrderRecords: array<skuOrderRecord>,
) => {
  // so this is a hook, remember
  let focusSkuOrderOpt = schema.skuOrder.rel.useRecordById(state.focusOnSkuOrderRecordId)
  let focusSkuOpt = schema.sku.rel.useRecordById(state.skuAttachments->first)

  <div>
    <Heading> {React.string(`SKU Orders`)} </Heading>
    <Table
      rowId={record => record.id}
      elements=skuOrderRecords
      columnDefs=[
        {
          header: `Tracking #`,
          accessor: so => so.trackingRecord.scalar.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `SKU`,
          accessor: so => {
            <div>
              {so.skuOrderSku.scalar.render()}
              <div>
                {so.skuOrderSku.rel.getRecord()
                ->Option.flatMap(sku =>
                  sku->skuHasImages
                    ? Some(
                        <Button
                          onClick={() => dispatch(Reducer.FocusOnSkuAttachments(sku))}
                          icon="attachment"
                          size="default"
                          variant="default">
                          {`View Photo(s)`->s}
                        </Button>,
                      )
                    : None
                )
                ->Option.getWithDefault(React.null)}
              </div>
              {focusSkuOpt->Option.mapWithDefault(React.null, sku =>
                <SkuAttachmentsDialog dispatch state sku />
              )}
            </div>
          },
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Desc`,
          accessor: so => so.externalProductName.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Expect#`,
          accessor: so => so.quantityExpected.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Received#`,
          accessor: so => so.quantityReceived.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Packed#`,
          accessor: so => so.quantityPacked.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Dest`,
          accessor: so => {
            <div>
              {so.skuOrderBoxDest.scalar.render()}
              {so.skuOrderBoxDest.rel.getRecord()
              ->Option.flatMap(bd =>
                bd.isSerialBox.read()
                  ? Some(
                      `This destination is intended ONLY for items with serial
numbers and their accompanying peripheral or similar products. If it seems like
this is an improper destination for this product, let us know before boxing!`,
                    )
                  : None
              )
              ->Option.mapWithDefault(React.null, msg =>
                <div
                  style={ReactDOM.Style.make(
                    ~fontSize=".7em",
                    ~fontStyle="italic",
                    ~backgroundColor="LightGoldenRodYellow",
                    // the double div solution is from here
                    // https://stackoverflow.com/questions/9769587/set-div-to-have-its-siblings-width
                    ~display="flex",
                    (),
                  )}>
                  <div style={ReactDOM.Style.make(~flexGrow="1", ~width="0", ())}> {msg->s} </div>
                </div>
              )}
            </div>
          },
          tdStyle: ReactDOM.Style.make(),
        },
        /* {
          header: `Receive Expected?`,
          accessor: so => so.skuOrderIsReceived.render(),
          tdStyle: ReactDOM.Style.make(~textAlign="center", ()),
        },
        {
          header: `Boxed?`,
          accessor: so => so.boxedCheckbox.render(),
          tdStyle: ReactDOM.Style.make(~textAlign="center", ()),
        }, */
        {
          header: `SKU Notes for this Order`,
          accessor: so => so.receivingNotes.render(),
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `Inspect`,
          accessor: so => parseRecordState(schema, so, state, dispatch).inspectionButton,
          tdStyle: ReactDOM.Style.make(),
        },
        {
          header: `➡️ ➡️ ➡️`,
          accessor: so => parseRecordState(schema, so, state, dispatch).activationButton,
          tdStyle: ReactDOM.Style.make(),
        },
      ]
    />
    {focusSkuOrderOpt->Option.mapWithDefault(React.null, record =>
      parseRecordState(schema, record, state, dispatch).dialog
    )}
  </div>
}
