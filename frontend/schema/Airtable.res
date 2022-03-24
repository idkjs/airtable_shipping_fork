type airtableFieldId
type airtableRawField = {
  name: string,
  @bs.as("type")
  _type: string,
}
@@warning("-30")

type airtableObjectMap
type airtableObjectMapComponent

type airtableRawView
type airtableRawTable = {primaryField: airtableRawField}
type airtableRawBase
type airtableRawRecord = {id: string}
type airtableRawRecordQueryResult = {records: array<airtableRawRecord>}
type airtableMoment
type airtableRawSortParam = {
  field: airtableRawField,
  direction: string,
}

type rec airtableAttachment = {
  id: string,
  url: string,
  filename: string,
  contentType: option<string>,
  sizeInBytes: option<int>,
  thumbnail: airtableAttachmentThumbnails,
}
and airtableAttachmentThumbnail = {
  thumbnailUrl: string,
  widthPx: int,
  heightPx: int,
}
and airtableAttachmentThumbnails = {
  small: option<airtableAttachmentThumbnail>,
  large: option<airtableAttachmentThumbnail>,
  full: option<airtableAttachmentThumbnail>,
}
and newAirtableAttachment = {url: string, filename: string}
and airtableAttachmentWriteFmt =
  WithExistingAttachment(airtableAttachment) | WithNewAttachment(newAirtableAttachment)

// their functions
@bs.module("@airtable/blocks/ui")
external useBase: unit => airtableRawBase = "useBase"
@bs.module("@airtable/blocks/ui")
external useRecords: airtableRawRecordQueryResult => array<airtableRawRecord> = "useRecords"
@bs.send @bs.return(nullable)
external getTableByName: (airtableRawBase, string) => option<airtableRawTable> =
  "getTableByNameIfExists"
@bs.send @bs.return(nullable)
external getViewByName: (airtableRawTable, string) => option<airtableRawView> =
  "getViewByNameIfExists"
@bs.send @bs.return(nullable)
external getFieldByName: (airtableRawTable, string) => option<airtableRawField> =
  "getFieldByNameIfExists"
@bs.send @bs.return(nullable)
external getRecordById: (airtableRawRecordQueryResult, string) => option<airtableRawRecord> =
  "getRecordByIdIfExists"
@bs.send
external createRecordAsync: (airtableRawTable, airtableObjectMap) => Js.Promise.t<string> =
  "createRecordAsync"
@bs.send
external deleteRecordsAsync: (airtableRawTable, array<airtableRawRecord>) => Js.Promise.t<unit> =
  "deleteRecordsAsync"

@bs.send
external format: (airtableMoment, unit) => string = "format"

@bs.send
external updateRecordAsync: (
  airtableRawTable,
  airtableRawRecord,
  airtableObjectMap,
) => Js.Promise.t<unit> = "updateRecordAsync"

@bs.module("@airtable/blocks/ui")
external useLoadableHookInternal: airtableRawRecordQueryResult => unit = "useLoadable"
// make the above chainable
let useLoadableHook: airtableRawRecordQueryResult => airtableRawRecordQueryResult = arrqr => {
  useLoadableHookInternal(arrqr)
  arrqr
}
@bs.module("@airtable/blocks/ui")
external useMultipleQueriesInternal: array<airtableRawRecordQueryResult> => unit = "useLoadable"
let useMultipleQueries: array<airtableRawRecordQueryResult> => array<
  airtableRawRecordQueryResult,
> = arrqr => {
  useMultipleQueriesInternal(arrqr)
  arrqr
}

@bs.module("@airtable/blocks/ui")
external useWatchable: (array<airtableRawRecordQueryResult>, array<string>) => unit = "useWatchable"

// this is ui thing, but we only use it in here
module CellRenderer = {
  @bs.module("@airtable/blocks/ui") @react.component
  external make: (~field: airtableRawField, ~record: airtableRawRecord) => React.element =
    "CellRenderer"
}

// my functions
@bs.module("./js_helpers")
external getString: (airtableRawRecord, airtableRawField) => string = "prepBareString"
@bs.module("./js_helpers")
external getStringOption: (airtableRawRecord, airtableRawField) => option<string> =
  "prepStringOption"
@bs.module("./js_helpers")
external getInt: (airtableRawRecord, airtableRawField) => int = "prepInt"
@bs.module("./js_helpers")
external getIntOption: (airtableRawRecord, airtableRawField) => option<int> = "prepIntOption"
@bs.module("./js_helpers")
external getBool: (airtableRawRecord, airtableRawField) => bool = "prepBool"
@bs.module("./js_helpers")
external getIntAsBool: (airtableRawRecord, airtableRawField) => bool = "prepIntAsBool"
@bs.module("./js_helpers")
external getMomentOption: (airtableRawRecord, airtableRawField) => option<airtableMoment> =
  "prepMomentOption"
@bs.module("./js_helpers")
external getMultipleAttachments: (
  airtableRawRecord,
  airtableRawField,
) => array<airtableAttachment> = "prepMultipleAttachments"

@bs.module("./js_helpers")
external getLinkedRecordQueryResult: (
  airtableRawRecord,
  airtableRawField,
  array<airtableRawField>,
  array<airtableRawSortParam>,
) => airtableRawRecordQueryResult = "prepRelFieldQueryResult"
@bs.module("./js_helpers")
external getTableRecordsQueryResult: (
  airtableRawTable,
  array<airtableRawField>,
  array<airtableRawSortParam>,
) => airtableRawRecordQueryResult = "selectRecordsFromTableOrView"
@bs.module("./js_helpers")
external getViewRecordsQueryResult: (
  airtableRawView,
  array<airtableRawField>,
  array<airtableRawSortParam>,
) => airtableRawRecordQueryResult = "selectRecordsFromTableOrView"

// from https://rescript-lang.org/docs/manual/latest/interop-cheatsheet#dangerous-type-cast
// generally this is dangerous
// but we want object maps to be polymorphic in a way that would be a PITA here
// so we throw away whatever the fuck the type is in the second of the tuple
external buildObjectMapComponent: ((airtableRawField, _)) => airtableObjectMapComponent =
  "%identity"

// look i want typing info
@bs.module external var_dump: _ => unit = "locutus/php/var/var_dump"

@bs.module("./js_helpers")
external buildAirtableObjectMap: array<airtableObjectMapComponent> => airtableObjectMap =
  "buildAirtableObjectMap"
@bs.module("./js_helpers")
external nowMoment: unit => airtableMoment = "moment"
