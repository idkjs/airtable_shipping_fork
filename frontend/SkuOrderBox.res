open Belt
open Schema
open Util
open SchemaDefinition

type potentialBox = {
  name: string,
  status: string,
  isEmpty: bool,
  notes: string,
  unboxedQty: int,
  getRecordId: unit => Js.Promise.t<recordId<boxRecord>>,
  underlyingRecord: option<boxRecord>,
}

let formatBoxNameWithNumber: (boxDestinationRecord, int) => string = (bdr, i) => {
  open Js.String2
  let paddedNumber = // box numbers are 0 padded 2 or 3 digit numbers
  (bdr.boxOffset.read() + i + 1000)
  ->// we add the 1000 to get enough zeroes in there
  Int.toString
  // if it's a serial box it's 2 long, otherwise 3
  ->sliceToEnd(~from=bdr.isSerialBox.read() ? -2 : -3)
  `${bdr.destinationPrefix.read()}-${paddedNumber}`
}

let findPotentialBoxes: (
  schema,
  boxDestinationRecord,
  int,
  bool,
) => result<array<potentialBox>, string> = (schema, bdr, unboxedQty, isForSerialItem) => {
  let boxes = bdr.boxes.rel.getRecords([schema.box.boxNumberOnlyField.sortDesc])

  let presentBoxNumbers = Set.Int.fromArray(boxes->Array.map(box => box.boxNumberOnly.read()))
  let expectedBoxNumbers =
    presentBoxNumbers->Set.Int.size > 0
      ? Set.Int.fromArray(
          // note that we need to have length for this inclusive range to be valid here
          Array.range(1, boxes->Array.length),
        )
      : Set.Int.empty

  let realToPotential: boxRecord => potentialBox = real => {
    name: real.boxName.read(),
    status: switch (real.isMaxBox.read(), real.isPenultimateBox.read(), real.isEmpty.read()) {
    | (true, _, _) => `Most recent box`
    | (_, true, _) => `Second most recent box`
    | (_, _, true) => `Other Empty Box`
    | _ => `A box with things in it`
    },
    isEmpty: real.isEmpty.read(),
    notes: real.boxNotes.read(),
    unboxedQty: unboxedQty,
    getRecordId: () => Js.Promise.resolve(real.id),
    underlyingRecord: Some(real),
  }

  // i want the symmetric difference -- everything that's not
  // present in both lists... the opposite of the intersection
  // https://en.wikipedia.org/wiki/Symmetric_difference
  let expectedButNotPresent = Set.Int.diff(expectedBoxNumbers, presentBoxNumbers)
  let presentButNotExpected = Set.Int.diff(presentBoxNumbers, expectedBoxNumbers)
  let noDupeNumbers = presentBoxNumbers->Set.Int.size == boxes->Array.length

  // almost all this function is dedicated to parsing out the potential errors and
  // describing them in close detail
  let errorMessage = switch (
    expectedButNotPresent->Set.Int.isEmpty,
    presentButNotExpected->Set.Int.isEmpty,
    noDupeNumbers,
  ) {
  // seems good if there is nothing in these sets
  | (true, true, true) =>
    isForSerialItem && !bdr.isSerialBox.read()
      ? `It appears that this item requires a serial number 
and yet it is routed to a destination that is not for serial numbered items.`
      : ``

  | _ => {
      let minMaxNum = set => (
        // we know the set has length
        set->Set.Int.minimum->Option.getExn |> formatBoxNameWithNumber(bdr),
        set->Set.Int.maximum->Option.getExn |> formatBoxNameWithNumber(bdr),
      )

      let toNumberList = set =>
        set->Set.Int.toArray->Array.map(formatBoxNameWithNumber(bdr)) |> joinWith(", ")
      let expectedSize = presentBoxNumbers->Set.Int.maximum->Option.getExn->Int.toString
      let actualSize = boxes->Array.length->Int.toString
      let expectMinMax = minMaxNum(expectedBoxNumbers)
      let presentMinMax = minMaxNum(presentBoxNumbers)

      `There is a potential data integrity issue with the list of boxes
that are currently in the airtable for this destination. Our expectation for this
destination is there will be ${expectedSize} boxes. There are, in fact, ${actualSize}
boxes listed. ${noDupeNumbers
        ? ""
        : "It looks like there is a duplicate box. "}
        
HINT: you should look at the boxes for this destination and make sure
the list looks right (no duplicate numbers, numbers counting strictly upward, no gaps
between the numbers.)

It seems like we SHOULD have every box in the range [${expectMinMax->first}] to [${expectMinMax->second}].
It seems like we DO have boxes in the range [${presentMinMax->first}] to [${presentMinMax->second}].

We expected to see the following box numbers but they were missing: [${expectedButNotPresent->toNumberList}]
We didn't expect to see the following box numbers: [${presentButNotExpected->toNumberList}]`
    }
  }

  switch errorMessage {
  | "" => {
      let newBox: potentialBox = {
        let newNumber =
          boxes->Array.get(0)->Option.mapWithDefault(1, box => box.boxNumberOnly.read() + 1)
        {
          name: formatBoxNameWithNumber(bdr, newNumber),
          status: `🆕 NEW 🆕`,
          notes: `Created by Receiving Tool`,
          isEmpty: true,
          unboxedQty: unboxedQty,
          getRecordId: () => {
            schema.box.crud.create([
              schema.box.boxNumberOnlyField.buildObjectMapComponent(newNumber),
              schema.box.boxDestField.buildObjectMapComponent(bdr),
              schema.box.boxNotesField.buildObjectMapComponent(`Created by Receiving Tool`),
            ])
          },
          underlyingRecord: None,
        }
      }
      let (empties, fullies) = if boxes->Array.length > 2 {
        boxes
        ->Array.sliceToEnd(2)
        ->Array.map(realToPotential)
        ->Array.partition(pbox => pbox.isEmpty)
      } else {
        ([], [])
      }

      Ok(
        // max box, then pen box, then new box, then empties, then fullies
        Array.concatMany([
          [
            // maxBox
            boxes->Array.get(0)->Option.map(realToPotential),
            // penultimate
            boxes->Array.get(1)->Option.map(realToPotential),
            Some(newBox),
            //boxes->Array.get(1),
          ]->Array.keepMap(identity),
          empties,
          fullies,
        ]),
      )
    }
  | err => Error(err)
  }
}
