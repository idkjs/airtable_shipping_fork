open Airtable
open Schema
open Util
open PipelineDialog
open Reducer
@@warning("-45")

type skuOrderTrackingState = {activationButton: React.element, dialog: React.element}

let parseRecordState: (
  schema,
  skuOrderTrackingRecord,
  state,
  action => _,
) => skuOrderTrackingState = (schema, sotr, state, dispatch) => {
  let dialogOpen = () => {
    dispatch(UpdateWarehouseNotes(sotr.warehouseNotes.read()))
    dispatch(FocusOnTrackingRecord(sotr))
  }
  let dialogClose = () => {
    dispatch(UnfocusTrackingRecord)
    dispatch(UpdateWarehouseNotes(""))
  }
  let saveWarehouseNotesAndClose = () => {
    dispatch(BlindlyPromise(() => sotr.warehouseNotes.updateAsync(state.warehouseNotes)))
    dialogClose()
  }
  let receiveTrackingNumberSaveNotesAndClose = () => {
    dispatch(BlindlyPromise(() => sotr.receivedTime.updateAsync(Some(nowMoment()))))
    saveWarehouseNotesAndClose()
  }
  let unreceiveTrackingNumberSaveNotesAndClose = () => {
    dispatch(BlindlyPromise(() => sotr.receivedTime.updateAsync(None)))
    saveWarehouseNotesAndClose()
  }

  let warehouseNotesOnChange = dispatch->onChangeHandler(v => UpdateWarehouseNotes(v))

  let canUnreceiveThisRecord = SkuOrderDialogState.parentCanBeUnreceived(
    schema,
    sotr,
    state,
    dispatch,
  )
  let cancelAndDontSaveButton =
    <CancelButton onClick=dialogClose> {s(`Don't save my changes`)} </CancelButton>
  let saveChangesToNotesButton =
    <PrimarySaveButton onClick=saveWarehouseNotesAndClose> {s(`Save changes`)} </PrimarySaveButton>
  let receiveAndSaveNotes =
    <PrimarySaveButton onClick=receiveTrackingNumberSaveNotesAndClose>
      {s(`Save Notes and Receive!`)}
    </PrimarySaveButton>
  let unreceiveAndSaveNotes =
    <WarningButton
      onClick=unreceiveTrackingNumberSaveNotesAndClose disabled={!canUnreceiveThisRecord}>
      {s(
        canUnreceiveThisRecord
          ? `Unreceive & Save Notes`
          : `Cannot Unreceive - Children are Received`,
      )}
    </WarningButton>

  let isReceived = sotr.isReceived.read()
  {
    activationButton: isReceived
      ? <EditButton onClick=dialogOpen> {s(`Edit/View`)} </EditButton>
      : <PrimaryActionButton onClick=dialogOpen> {s(`Receive`)} </PrimaryActionButton>,
    dialog: {
      @react.component
      let make = () =>
        <PipelineDialog
          header={isReceived ? `Edit Tracking Record` : `Receive Tracking Record`}
          actionButtons={isReceived
            ? [unreceiveAndSaveNotes, cancelAndDontSaveButton, saveChangesToNotesButton]
            : [cancelAndDontSaveButton, receiveAndSaveNotes]}
          closeCancel=dialogClose>
          <Subheading> {s(`Review Receiving Notes from JoCo Cruise`)} </Subheading>
          {sotr.jocoNotes.render()}
          <Subheading>
            {s(isReceived ? `Edit Warehouse Receiving Notes` : `Enter Warehouse Receiving Notes`)}
          </Subheading>
          <textarea
            style={ReactDOM.Style.make(~marginBottom=`16px`, ~width="100%", ())}
            value=state.warehouseNotes
            onChange=warehouseNotesOnChange
            rows=5
          />
        </PipelineDialog>

      make()
    },
  }
}
