open PipelineDialog
open Util
open Schema
open Belt
open Reducer
open SkuOrderBox
@@warning("-45")

type skuOrderDialogVars = {
  // data
  skuOrder: skuOrderRecord,
  sku: skuRecord,
  dest: boxDestinationRecord,
  tracking: skuOrderTrackingRecord,
  // actions
  dispatch: action => unit,
  closeCancel: unit => unit,
  dialogClose: action,
  boxSearchClear: action,
  persistQtyReceivedFromState: action,
  persistQtyReceivedOfOne: action,
  persistReceivingNotesFromState: action,
  persistIsReceivedCheckbox: action,
  persistSerialNumberAndSerializedSkuNameFromState: action,
  hasAnythingBeenPacked: bool,
  persistUnreceive: action,
  // display vars
  qtyToReceive: int,
  qtyToReceiveOnChange: ReactEvent.Form.t => unit,
  receivingNotes: string,
  receivingNotesOnChange: ReactEvent.Form.t => unit,
  serialNumber: string,
  serialNumberLooksGood: bool,
  serialNumberOnChange: ReactEvent.Form.t => unit,
  boxSearchString: string,
  boxSearchStringOnChange: ReactEvent.Form.t => unit,
  qtyToBox: potentialBox => int,
  qtyToBoxOnChange: (potentialBox, ReactEvent.Form.t) => unit,
  boxNotes: potentialBox => string,
  boxNotesOnChange: (potentialBox, ReactEvent.Form.t) => unit,
  boxesToDisplay: array<potentialBox>,
  filterToSinglePotentialBox: option<potentialBox>,
  isFilteredToSinglePotentialBox: bool,
  noBoxSearchResults: bool,
  createNewBox: (potentialBox, unit) => unit,
  packBox: (potentialBox, boxRecord, int, string, unit) => unit,
  packingBoxIsLoading: bool,
  packingBox: option<boxRecord>,
  deleteBoxLine: (boxLineRecord, unit) => unit,
}

module ReceiveUnserialedSku = {
  @react.component
  let make = (~dialogVars: skuOrderDialogVars) => {
    let {
      skuOrder,
      sku,
      closeCancel,
      dispatch,
      persistQtyReceivedFromState,
      persistReceivingNotesFromState,
      dialogClose,
      tracking,
      qtyToReceive,
      qtyToReceiveOnChange,
      receivingNotes,
      receivingNotesOnChange,
    } = dialogVars

    <PipelineDialog
      header={`Receive & QC: ${sku.skuName.read()}`}
      actionButtons=[
        <CancelButton onClick=closeCancel> {s(`Cancel`)} </CancelButton>,
        <SecondarySaveButton
          disabled={qtyToReceive < 1}
          onClick={() =>
            dispatch->multi([
              persistQtyReceivedFromState,
              persistReceivingNotesFromState,
              dialogClose,
            ])}>
          {s(qtyToReceive > 0 ? `Save and Close` : `Must Receive > 0`)}
        </SecondarySaveButton>,
        <PrimarySaveButton
          disabled={qtyToReceive < 1}
          onClick={() =>
            dispatch->multi([persistQtyReceivedFromState, persistReceivingNotesFromState])}>
          {s(qtyToReceive > 0 ? `Save and Continue` : `Must Receive > 0`)}
        </PrimarySaveButton>,
      ]
      closeCancel>
      <Subheading> {`Tracking Number Receiving Notes`->s} </Subheading>
      {tracking.jocoNotes.render()}
      <VSpace px=20 />
      <Table
        rowId={() => `${tracking.id}_rcvtab`}
        elements=[()]
        columnDefs=[
          {
            header: `SKU`,
            accessor: () => sku.skuName.read()->s,
            tdStyle: ReactDOM.Style.make(),
          },
          {
            header: `Expected`,
            accessor: () => skuOrder.quantityExpected.read()->itos,
            tdStyle: ReactDOM.Style.make(~fontSize="1.5em", ()),
          },
          {
            header: `Qty To Receive`,
            accessor: () =>
              <input
                onChange=qtyToReceiveOnChange
                type_="number"
                value={qtyToReceive->Int.toString}
                style={ReactDOM.Style.make(~fontSize="1.5em", ~width="77px", ())}
              />,
            tdStyle: ReactDOM.Style.make(~width="88px", ()),
          },
          {
            header: `QC/Receiving Notes`,
            accessor: () =>
              <textarea
                style={ReactDOM.Style.make(~width="100%", ())}
                value=receivingNotes
                onChange=receivingNotesOnChange
                rows=6
              />,
            tdStyle: ReactDOM.Style.make(~width="40%", ()),
          },
        ]
      />
      <VSpace px=40 />
    </PipelineDialog>
  }
}

module ReceiveSerialedSku = {
  @react.component
  let make = (~dialogVars: skuOrderDialogVars) => {
    let {
      sku,
      closeCancel,
      dispatch,
      persistQtyReceivedOfOne,
      persistReceivingNotesFromState,
      serialNumberLooksGood,
      persistSerialNumberAndSerializedSkuNameFromState,
      dialogClose,
      tracking,
      serialNumber,
      serialNumberOnChange,
      receivingNotes,
      receivingNotesOnChange,
    } = dialogVars
    <PipelineDialog
      header={`Enter Serial Number & QC: ${sku.skuName.read()}`}
      actionButtons=[
        <CancelButton onClick=closeCancel> {s(`Cancel`)} </CancelButton>,
        <SecondarySaveButton
          disabled={!serialNumberLooksGood}
          onClick={() =>
            dispatch->multi([
              persistSerialNumberAndSerializedSkuNameFromState,
              persistQtyReceivedOfOne,
              persistReceivingNotesFromState,
              dialogClose,
            ])}>
          {s(serialNumberLooksGood ? `Save and Close` : `Enter a serial number`)}
        </SecondarySaveButton>,
        <PrimarySaveButton
          disabled={!serialNumberLooksGood}
          onClick={() =>
            dispatch->multi([
              persistSerialNumberAndSerializedSkuNameFromState,
              persistQtyReceivedOfOne,
              persistReceivingNotesFromState,
            ])}>
          {s(serialNumberLooksGood ? `Save and Continue` : `Enter a serial number`)}
        </PrimarySaveButton>,
      ]
      closeCancel>
      <Subheading> {`Tracking Number Receiving Notes`->s} </Subheading>
      {tracking.jocoNotes.render()}
      <VSpace px=20 />
      <Subheading> {`Enter the serial number for this item`->s} </Subheading>
      <input
        onChange=serialNumberOnChange
        type_="text"
        value={serialNumber}
        style={ReactDOM.Style.make(~fontSize="1.5em", ~width="400px", ())}
      />
      <Subheading> {`Any notes on this item?`->s} </Subheading>
      <textarea
        style={ReactDOM.Style.make(~width="100%", ())}
        value=receivingNotes
        onChange=receivingNotesOnChange
        rows=6
      />
    </PipelineDialog>
  }
}

module BoxSku = {
  @react.component
  let make = (~dialogVars: skuOrderDialogVars) => {
    let {
      dispatch,
      sku,
      skuOrder,
      closeCancel,
      boxSearchString,
      boxSearchStringOnChange,
      qtyToBox,
      qtyToBoxOnChange,
      boxNotes,
      boxNotesOnChange,
      boxesToDisplay,
      filterToSinglePotentialBox,
      isFilteredToSinglePotentialBox,
      noBoxSearchResults,
      dest,
      receivingNotes,
      receivingNotesOnChange,
      createNewBox,
      packingBoxIsLoading,
      packBox,
      boxSearchClear,
      persistUnreceive,
      hasAnythingBeenPacked,
      dialogClose,
      packingBox,
    } = dialogVars

    let clearSearchBtn =
      <CancelButton onClick={() => dispatch(boxSearchClear)}> {`Clear Search`->s} </CancelButton>

    <PipelineDialog
      header={`Box ${sku.skuName.read()}`}
      actionButtons=[
        <CancelButton onClick=closeCancel> {s(`Cancel`)} </CancelButton>,
        <WarningButton
          disabled={hasAnythingBeenPacked}
          onClick={() => dispatch->multi([persistUnreceive, dialogClose])}>
          {s(
            hasAnythingBeenPacked
              ? `Cannot unreceive while some of this SKU is boxed`
              : `Unreceive This Sku. Eek!`,
          )}
        </WarningButton>,
      ]
      closeCancel>
      <Subheading> {`Narrow Box Results`->s} </Subheading>
      <input
        onChange={boxSearchStringOnChange}
        type_="text"
        value={boxSearchString}
        style={ReactDOM.Style.make(~fontSize="1.5em", ~width="400px", ())}
      />
      {clearSearchBtn}
      <Subheading> {`Pick a box to receive into`->s} </Subheading>
      {noBoxSearchResults
        ? <div> <p> {`No results found for query`->s} </p> {clearSearchBtn} </div>
        : <Table
            rowId={box => `${box.name}_selbo`}
            elements=boxesToDisplay
            columnDefs=[
              {
                header: `Empty?`,
                accessor: box => (box.isEmpty ? `✅🌈` : `⛔🙅`)->s,
                tdStyle: ReactDOM.Style.make(~fontSize="1.7em", ~textAlign="center", ()),
              },
              {
                header: `Box Name`,
                accessor: box => box.name->s,
                tdStyle: ReactDOM.Style.make(~fontSize="1.3em", ~textAlign="center", ()),
              },
              {
                header: `Status`,
                accessor: box => box.status->s,
                tdStyle: ReactDOM.Style.make(),
              },
              {
                header: `Box Notes`,
                accessor: box => box.notes->s,
                tdStyle: ReactDOM.Style.make(),
              },
              {
                header: `Action`,
                accessor: box => {
                  isFilteredToSinglePotentialBox
                    ? clearSearchBtn
                    : <PrimarySaveButton
                        onClick={() => UpdateBoxSearchString(dest, box.name)->dispatch}>
                        {`Select`->s}
                      </PrimarySaveButton>
                },
                tdStyle: ReactDOM.Style.make(~textAlign="center", ()),
              },
            ]
          />}
      {switch filterToSinglePotentialBox {
      | None => React.null
      | Some(box) =>
        <div>
          {// view existing box contents, if any are present
          packingBox->Option.mapWithDefault(React.null, existingBox =>
            switch existingBox.boxLines.rel.getRecords([]) {
            | [] => React.null
            | boxLines =>
              <div>
                <Subheading> {`Existing Box Contents`->s} </Subheading>
                <Table
                  rowId={bl => `${bl.name.read()}_viewextantbo`}
                  elements=boxLines
                  columnDefs=[
                    {
                      header: `Box`,
                      accessor: bl => bl.boxRecord.scalar.render(),
                      tdStyle: ReactDOM.Style.make(),
                    },
                    {
                      header: `Sku`,
                      accessor: bl => bl.boxLineSku.scalar.render(),
                      tdStyle: ReactDOM.Style.make(),
                    },
                    {
                      header: `Qty`,
                      accessor: bl => bl.qty.render(),
                      tdStyle: ReactDOM.Style.make(),
                    },
                  ]
                />
              </div>
            }
          )}
          // actually do the receiving
          <Subheading> {(`Receive ${sku.skuName.read()} into ${box.name}`)->s} </Subheading>
          <Table
            rowId={box => `${box.name}_packbo`}
            elements=[box]
            columnDefs=[
              {
                header: `Sku`,
                accessor: _ => skuOrder.skuOrderSku.scalar.render(),
                tdStyle: ReactDOM.Style.make(),
              },
              {
                header: `Qty Unboxed`,
                accessor: pb => pb.unboxedQty->itos,
                tdStyle: ReactDOM.Style.make(~fontSize="1.7em", ~textAlign="center", ()),
              },
              {
                header: `Box Qty`,
                accessor: pb =>
                  <input
                    onChange={pb->qtyToBoxOnChange}
                    type_="number"
                    value={pb->qtyToBox->Int.toString}
                    style={ReactDOM.Style.make(~fontSize="1.5em", ~width="77px", ())}
                  />,
                tdStyle: ReactDOM.Style.make(~fontSize="1.7em", ~textAlign="center", ()),
              },
              {
                header: `Box-Level Notes`,
                accessor: pb =>
                  <textarea
                    style={ReactDOM.Style.make(~width="100%", ())}
                    value={pb->boxNotes}
                    onChange={pb->boxNotesOnChange}
                    rows=6
                  />,
                tdStyle: ReactDOM.Style.make(~width="40%", ()),
              },
              {
                header: `Box it`,
                accessor: pb => {
                  switch (pb.underlyingRecord, packingBoxIsLoading) {
                  | (None, false) =>
                    <SecondarySaveButton
                      onClick={createNewBox(pb)}
                      style={ReactDOM.Style.make(~padding="10px inherit", ())}>
                      {(`Create box ${pb.name}`)->s}
                    </SecondarySaveButton>
                  | (None, true) =>
                    <SecondarySaveButton
                      disabled=true
                      onClick={() => ()}
                      style={ReactDOM.Style.make(~padding="10px inherit", ())}>
                      {`...Loading...`->s}
                    </SecondarySaveButton>
                  | (Some(reco), _) =>
                    <PrimarySaveButton
                      onClick={packBox(pb, reco, pb->qtyToBox, pb->boxNotes)}
                      style={ReactDOM.Style.make(~padding="10px inherit", ())}>
                      {(`Receive ${pb->qtyToBox->Int.toString}`)->s} <br /> {(`into ${pb.name}`)->s}
                    </PrimarySaveButton>
                  }
                },
                tdStyle: ReactDOM.Style.make(),
              },
            ]
          />
          <Subheading> {`Review/Edit Receiving Notes for this entire SKUOrder`->s} </Subheading>
          <textarea
            style={ReactDOM.Style.make(~width="100%", ())}
            value=receivingNotes
            onChange=receivingNotesOnChange
            rows=6
          />
        </div>
      }}
      <VSpace px=40 />
    </PipelineDialog>
  }
}

module SpectatePackedBoxes = {
  @react.component
  let make = (
    ~dialogVars: skuOrderDialogVars,
    ~boxesToSpectate: array<boxRecord>,
    ~isThereMoreToBox: bool,
  ) => {
    let {
      closeCancel,
      sku,
      boxSearchClear,
      receivingNotes,
      receivingNotesOnChange,
      persistReceivingNotesFromState,
      dispatch,
      dialogClose,
      deleteBoxLine,
    } = dialogVars
    let packedInNBoxes = boxesToSpectate->Array.length
    <PipelineDialog
      header={`This SKU Order is Packed into ${packedInNBoxes->Int.toString} Box(es)`}
      actionButtons={[
        <CancelButton onClick=closeCancel> {s(`Close Window`)} </CancelButton>,
        isThereMoreToBox
          ? <PrimaryActionButton
              onClick={() => dispatch->multi([persistReceivingNotesFromState, boxSearchClear])}>
              {s(`Save Notes & Keep Boxing This SKU Order`)}
            </PrimaryActionButton>
          : <SecondaryActionButton
              onClick={() => dispatch->multi([persistReceivingNotesFromState, dialogClose])}>
              {s(`Save And Close`)}
            </SecondaryActionButton>,
      ]}
      closeCancel>
      <div> {boxesToSpectate->Array.mapWithIndex((idx, box) =>
          <div>
            <Subheading>
              {(`Box ${(idx + 1)->Int.toString} of ${packedInNBoxes->Int.toString}`)->s}
            </Subheading>
            <Table
              rowId={boxLine => boxLine.name.read()}
              elements={box.boxLines.rel.getRecords([])}
              columnDefs=[
                {
                  header: `Box`,
                  accessor: bl => bl.boxRecord.scalar.render(),
                  tdStyle: ReactDOM.Style.make(),
                },
                {
                  header: `Sku`,
                  accessor: bl => bl.boxLineSku.scalar.render(),
                  tdStyle: ReactDOM.Style.make(),
                },
                {
                  header: `Qty`,
                  accessor: bl => bl.qty.render(),
                  tdStyle: ReactDOM.Style.make(),
                },
                {
                  header: `Box Specific Notes`,
                  accessor: _ => box.boxNotes.render(),
                  tdStyle: ReactDOM.Style.make(),
                },
                {
                  header: `🙀 👻 🔥`,
                  accessor: bl =>
                    <WarningButton
                      onClick={deleteBoxLine(bl)}
                      // only enable for the sku in question
                      disabled={bl.boxLineSku.rel.getRecord()->Option.mapWithDefault(true, reco =>
                        reco.id !== sku.id
                      )}>
                      {`Remove this from the box`->s}
                    </WarningButton>,
                  tdStyle: ReactDOM.Style.make(),
                },
              ]
            />
            <VSpace px=20 />
          </div>
        )->React.array} <Subheading>
          {`Review/Edit Receiving Notes for this entire SKUOrder`->s}
        </Subheading> <textarea
          style={ReactDOM.Style.make(~width="100%", ())}
          value=receivingNotes
          onChange=receivingNotesOnChange
          rows=6
        /> <VSpace px=40 /> </div>
    </PipelineDialog>
  }
}

module DataCorruption = {
  @react.component
  let make = (~formattedErrorText: string, ~closeCancel: unit => _) =>
    <PipelineDialog
      header=`Data Corruption`
      actionButtons=[
        <CancelButton onClick=closeCancel> {s(`Ok, We'll Fix It 😔`)} </CancelButton>,
      ]
      closeCancel>
      <Subheading>
        {`Review these items and make the necessary corrections to move on`->s}
      </Subheading>
      <pre> {formattedErrorText->s} </pre>
    </PipelineDialog>
}
