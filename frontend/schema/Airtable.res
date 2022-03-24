type airtableFieldId
type airtableRawField = {
  name: string,
  @as("type")
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
@module("@airtable/blocks/ui")
external useBase: unit => airtableRawBase = "useBase"
@module("@airtable/blocks/ui")
external useRecords: airtableRawRecordQueryResult => array<airtableRawRecord> = "useRecords"
@send @return(nullable)
external getTableByName: (airtableRawBase, string) => option<airtableRawTable> =
  "getTableByNameIfExists"
@send @return(nullable)
external getViewByName: (airtableRawTable, string) => option<airtableRawView> =
  "getViewByNameIfExists"
@send @return(nullable)
external getFieldByName: (airtableRawTable, string) => option<airtableRawField> =
  "getFieldByNameIfExists"
@send @return(nullable)
external getRecordById: (airtableRawRecordQueryResult, string) => option<airtableRawRecord> =
  "getRecordByIdIfExists"
@send
external createRecordAsync: (airtableRawTable, airtableObjectMap) => Js.Promise.t<string> =
  "createRecordAsync"
@send
external deleteRecordsAsync: (airtableRawTable, array<airtableRawRecord>) => Js.Promise.t<unit> =
  "deleteRecordsAsync"

@send
external format: (airtableMoment, unit) => string = "format"

@send
external updateRecordAsync: (
  airtableRawTable,
  airtableRawRecord,
  airtableObjectMap,
) => Js.Promise.t<unit> = "updateRecordAsync"

@module("@airtable/blocks/ui")
external useLoadableHookInternal: airtableRawRecordQueryResult => unit = "useLoadable"
// make the above chainable
let useLoadableHook: airtableRawRecordQueryResult => airtableRawRecordQueryResult = arrqr => {
  useLoadableHookInternal(arrqr)
  arrqr
}
@module("@airtable/blocks/ui")
external useMultipleQueriesInternal: array<airtableRawRecordQueryResult> => unit = "useLoadable"
let useMultipleQueries: array<airtableRawRecordQueryResult> => array<
  airtableRawRecordQueryResult,
> = arrqr => {
  useMultipleQueriesInternal(arrqr)
  arrqr
}

@module("@airtable/blocks/ui")
external useWatchable: (array<airtableRawRecordQueryResult>, array<string>) => unit = "useWatchable"

// this is ui thing, but we only use it in here
module CellRenderer = {
  @module("@airtable/blocks/ui") @react.component
  external make: (~field: airtableRawField, ~record: airtableRawRecord) => React.element =
    "CellRenderer"
}

// my functions
@module("./js_helpers")
external getString: (airtableRawRecord, airtableRawField) => string = "prepBareString"
@module("./js_helpers")
external getStringOption: (airtableRawRecord, airtableRawField) => option<string> =
  "prepStringOption"
@module("./js_helpers")
external getInt: (airtableRawRecord, airtableRawField) => int = "prepInt"
@module("./js_helpers")
external getIntOption: (airtableRawRecord, airtableRawField) => option<int> = "prepIntOption"
@module("./js_helpers")
external getBool: (airtableRawRecord, airtableRawField) => bool = "prepBool"
@module("./js_helpers")
external getIntAsBool: (airtableRawRecord, airtableRawField) => bool = "prepIntAsBool"
@module("./js_helpers")
external getMomentOption: (airtableRawRecord, airtableRawField) => option<airtableMoment> =
  "prepMomentOption"
@module("./js_helpers")
external getMultipleAttachments: (
  airtableRawRecord,
  airtableRawField,
) => array<airtableAttachment> = "prepMultipleAttachments"

@module("./js_helpers")
external getLinkedRecordQueryResult: (
  airtableRawRecord,
  airtableRawField,
  array<airtableRawField>,
  array<airtableRawSortParam>,
) => airtableRawRecordQueryResult = "prepRelFieldQueryResult"
@module("./js_helpers")
external getTableRecordsQueryResult: (
  airtableRawTable,
  array<airtableRawField>,
  array<airtableRawSortParam>,
) => airtableRawRecordQueryResult = "selectRecordsFromTableOrView"
@module("./js_helpers")
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
@module external var_dump: _ => unit = "locutus/php/var/var_dump"

@module("./js_helpers")
external buildAirtableObjectMap: array<airtableObjectMapComponent> => airtableObjectMap =
  "buildAirtableObjectMap"
@module("./js_helpers")
external nowMoment: unit => airtableMoment = "moment"
