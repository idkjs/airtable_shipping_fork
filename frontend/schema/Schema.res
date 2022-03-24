
open Airtable
open SchemaDefinition
open GenericSchema

// warnings that complain about matching fields in mut recursive types
// and overlapping labels
// and we dgaf in this case... it's p much of intentional
@@warning("-30")
@@warning("-45")

type rec skuOrderTrackingRecord = {
      id: recordId<skuOrderTrackingRecord>,
      trackingNumber: readWriteScalarRecordField<string>,
trackingLink: readOnlyScalarRecordField<string>,
skuOrders: relRecordField<multipleRelField<skuOrderRecord>,readOnlyScalarRecordField<string>>,
isReceived: readOnlyScalarRecordField<bool>,
shipDate: readWriteScalarRecordField<option<airtableMoment>>,
receivedTime: readWriteScalarRecordField<option<airtableMoment>>,
jocoNotes: readWriteScalarRecordField<string>,
warehouseNotes: readWriteScalarRecordField<string>,
    } and skuOrderRecord = {
      id: recordId<skuOrderRecord>,
      orderName: readOnlyScalarRecordField<string>,
trackingRecord: relRecordField<singleRelField<skuOrderTrackingRecord>,readOnlyScalarRecordField<string>>,
skuOrderSku: relRecordField<singleRelField<skuRecord>,readOnlyScalarRecordField<string>>,
skuOrderBoxLines: relRecordField<multipleRelField<boxLineRecord>,readOnlyScalarRecordField<string>>,
skuOrderBoxDest: relRecordField<singleRelField<boxDestinationRecord>,readOnlyScalarRecordField<string>>,
quantityExpected: readWriteScalarRecordField<int>,
quantityReceived: readWriteScalarRecordField<option<int>>,
quantityPacked: readOnlyScalarRecordField<int>,
boxedCheckbox: readWriteScalarRecordField<bool>,
externalProductName: readWriteScalarRecordField<string>,
skuOrderIsReceived: readWriteScalarRecordField<bool>,
receivingNotes: readWriteScalarRecordField<string>,
    } and skuRecord = {
      id: recordId<skuRecord>,
      skuName: readWriteScalarRecordField<string>,
serialNumber: readWriteScalarRecordField<string>,
isSerialRequired: readOnlyScalarRecordField<bool>,
lifetimeOrderQty: readOnlyScalarRecordField<int>,
skuAttachments: readWriteScalarRecordField<array<airtableAttachment>>,
    } and boxDestinationRecord = {
      id: recordId<boxDestinationRecord>,
      destName: readOnlyScalarRecordField<string>,
boxes: relRecordField<multipleRelField<boxRecord>,readOnlyScalarRecordField<string>>,
currentMaximalBoxNumber: readOnlyScalarRecordField<int>,
destinationPrefix: readWriteScalarRecordField<string>,
boxOffset: readWriteScalarRecordField<int>,
isSerialBox: readWriteScalarRecordField<bool>,
    } and boxRecord = {
      id: recordId<boxRecord>,
      boxName: readOnlyScalarRecordField<string>,
boxLines: relRecordField<multipleRelField<boxLineRecord>,readOnlyScalarRecordField<string>>,
boxDest: relRecordField<singleRelField<boxDestinationRecord>,readOnlyScalarRecordField<string>>,
boxNumberOnly: readWriteScalarRecordField<int>,
isMaxBox: readOnlyScalarRecordField<bool>,
isPenultimateBox: readOnlyScalarRecordField<bool>,
isEmpty: readOnlyScalarRecordField<bool>,
boxNotes: readWriteScalarRecordField<string>,
    } and boxLineRecord = {
      id: recordId<boxLineRecord>,
      name: readOnlyScalarRecordField<string>,
boxRecord: relRecordField<singleRelField<boxRecord>,readOnlyScalarRecordField<string>>,
boxLineSku: relRecordField<singleRelField<skuRecord>,readOnlyScalarRecordField<string>>,
boxLineSkuOrder: relRecordField<singleRelField<skuOrderRecord>,readOnlyScalarRecordField<string>>,
qty: readWriteScalarRecordField<int>,
    } and skuOrderTrackingTable = {
      rel: multipleRelField<skuOrderTrackingRecord>,
      crud: tableRecordOperations<skuOrderTrackingRecord>,
      hasTrackingNumbersView: multipleRelField<skuOrderTrackingRecord>,
      trackingNumberField: tableSchemaField<skuOrderTrackingRecord, string>,
trackingLinkField: tableSchemaField<skuOrderTrackingRecord, string>,
skuOrdersField: tableSchemaField<skuOrderTrackingRecord, array<skuOrderRecord>>,
isReceivedField: tableSchemaField<skuOrderTrackingRecord, bool>,
shipDateField: tableSchemaField<skuOrderTrackingRecord, option<airtableMoment>>,
receivedTimeField: tableSchemaField<skuOrderTrackingRecord, option<airtableMoment>>,
jocoNotesField: tableSchemaField<skuOrderTrackingRecord, string>,
warehouseNotesField: tableSchemaField<skuOrderTrackingRecord, string>,
    } and skuOrderTable = {
      rel: multipleRelField<skuOrderRecord>,
      crud: tableRecordOperations<skuOrderRecord>,
      
      orderNameField: tableSchemaField<skuOrderRecord, string>,
trackingRecordField: tableSchemaField<skuOrderRecord, skuOrderTrackingRecord>,
skuOrderSkuField: tableSchemaField<skuOrderRecord, skuRecord>,
skuOrderBoxLinesField: tableSchemaField<skuOrderRecord, array<boxLineRecord>>,
skuOrderBoxDestField: tableSchemaField<skuOrderRecord, boxDestinationRecord>,
quantityExpectedField: tableSchemaField<skuOrderRecord, int>,
quantityReceivedField: tableSchemaField<skuOrderRecord, option<int>>,
quantityPackedField: tableSchemaField<skuOrderRecord, int>,
boxedCheckboxField: tableSchemaField<skuOrderRecord, bool>,
externalProductNameField: tableSchemaField<skuOrderRecord, string>,
skuOrderIsReceivedField: tableSchemaField<skuOrderRecord, bool>,
receivingNotesField: tableSchemaField<skuOrderRecord, string>,
    } and skuTable = {
      rel: multipleRelField<skuRecord>,
      crud: tableRecordOperations<skuRecord>,
      
      skuNameField: tableSchemaField<skuRecord, string>,
serialNumberField: tableSchemaField<skuRecord, string>,
isSerialRequiredField: tableSchemaField<skuRecord, bool>,
lifetimeOrderQtyField: tableSchemaField<skuRecord, int>,
skuAttachmentsField: tableSchemaField<skuRecord, array<airtableAttachment>>,
    } and boxDestinationTable = {
      rel: multipleRelField<boxDestinationRecord>,
      crud: tableRecordOperations<boxDestinationRecord>,
      
      destNameField: tableSchemaField<boxDestinationRecord, string>,
boxesField: tableSchemaField<boxDestinationRecord, array<boxRecord>>,
currentMaximalBoxNumberField: tableSchemaField<boxDestinationRecord, int>,
destinationPrefixField: tableSchemaField<boxDestinationRecord, string>,
boxOffsetField: tableSchemaField<boxDestinationRecord, int>,
isSerialBoxField: tableSchemaField<boxDestinationRecord, bool>,
    } and boxTable = {
      rel: multipleRelField<boxRecord>,
      crud: tableRecordOperations<boxRecord>,
      
      boxNameField: tableSchemaField<boxRecord, string>,
boxLinesField: tableSchemaField<boxRecord, array<boxLineRecord>>,
boxDestField: tableSchemaField<boxRecord, boxDestinationRecord>,
boxNumberOnlyField: tableSchemaField<boxRecord, int>,
isMaxBoxField: tableSchemaField<boxRecord, bool>,
isPenultimateBoxField: tableSchemaField<boxRecord, bool>,
isEmptyField: tableSchemaField<boxRecord, bool>,
boxNotesField: tableSchemaField<boxRecord, string>,
    } and boxLineTable = {
      rel: multipleRelField<boxLineRecord>,
      crud: tableRecordOperations<boxLineRecord>,
      
      nameField: tableSchemaField<boxLineRecord, string>,
boxRecordField: tableSchemaField<boxLineRecord, boxRecord>,
boxLineSkuField: tableSchemaField<boxLineRecord, skuRecord>,
boxLineSkuOrderField: tableSchemaField<boxLineRecord, skuOrderRecord>,
qtyField: tableSchemaField<boxLineRecord, int>,
    }

type schema = {
  skuOrderTracking: skuOrderTrackingTable,
skuOrder: skuOrderTable,
sku: skuTable,
boxDestination: boxDestinationTable,
box: boxTable,
boxLine: boxLineTable,
}

let rec skuOrderTrackingRecordBuilder: (genericSchema, airtableRawRecord) => skuOrderTrackingRecord = (gschem, rawRec) => {
      id: rawRec.id,
      trackingNumber: getField(gschem,"trackingNumber").string.buildReadWrite(rawRec),
trackingLink: getField(gschem,"trackingLink").string.buildReadOnly(rawRec),
skuOrders: {rel: asMultipleRelField(getQueryableRelField(gschem,"skuOrders", skuOrderRecordBuilder, rawRec)), scalar: getField(gschem,"skuOrders").string.buildReadOnly(rawRec)},
isReceived: getField(gschem,"isReceived").intBool.buildReadOnly(rawRec),
shipDate: getField(gschem,"shipDate").momentOption.buildReadWrite(rawRec),
receivedTime: getField(gschem,"receivedTime").momentOption.buildReadWrite(rawRec),
jocoNotes: getField(gschem,"jocoNotes").string.buildReadWrite(rawRec),
warehouseNotes: getField(gschem,"warehouseNotes").string.buildReadWrite(rawRec),
    } and skuOrderRecordBuilder: (genericSchema, airtableRawRecord) => skuOrderRecord = (gschem, rawRec) => {
      id: rawRec.id,
      orderName: getField(gschem,"orderName").string.buildReadOnly(rawRec),
trackingRecord: {rel: asSingleRelField(getQueryableRelField(gschem,"trackingRecord", skuOrderTrackingRecordBuilder, rawRec)), scalar: getField(gschem,"trackingRecord").string.buildReadOnly(rawRec)},
skuOrderSku: {rel: asSingleRelField(getQueryableRelField(gschem,"skuOrderSku", skuRecordBuilder, rawRec)), scalar: getField(gschem,"skuOrderSku").string.buildReadOnly(rawRec)},
skuOrderBoxLines: {rel: asMultipleRelField(getQueryableRelField(gschem,"skuOrderBoxLines", boxLineRecordBuilder, rawRec)), scalar: getField(gschem,"skuOrderBoxLines").string.buildReadOnly(rawRec)},
skuOrderBoxDest: {rel: asSingleRelField(getQueryableRelField(gschem,"skuOrderBoxDest", boxDestinationRecordBuilder, rawRec)), scalar: getField(gschem,"skuOrderBoxDest").string.buildReadOnly(rawRec)},
quantityExpected: getField(gschem,"quantityExpected").int.buildReadWrite(rawRec),
quantityReceived: getField(gschem,"quantityReceived").intOpt.buildReadWrite(rawRec),
quantityPacked: getField(gschem,"quantityPacked").int.buildReadOnly(rawRec),
boxedCheckbox: getField(gschem,"boxedCheckbox").bool.buildReadWrite(rawRec),
externalProductName: getField(gschem,"externalProductName").string.buildReadWrite(rawRec),
skuOrderIsReceived: getField(gschem,"skuOrderIsReceived").bool.buildReadWrite(rawRec),
receivingNotes: getField(gschem,"receivingNotes").string.buildReadWrite(rawRec),
    } and skuRecordBuilder: (genericSchema, airtableRawRecord) => skuRecord = (gschem, rawRec) => {
      id: rawRec.id,
      skuName: getField(gschem,"skuName").string.buildReadWrite(rawRec),
serialNumber: getField(gschem,"serialNumber").string.buildReadWrite(rawRec),
isSerialRequired: getField(gschem,"isSerialRequired").intBool.buildReadOnly(rawRec),
lifetimeOrderQty: getField(gschem,"lifetimeOrderQty").int.buildReadOnly(rawRec),
skuAttachments: getField(gschem,"skuAttachments").attachments.buildReadWrite(rawRec),
    } and boxDestinationRecordBuilder: (genericSchema, airtableRawRecord) => boxDestinationRecord = (gschem, rawRec) => {
      id: rawRec.id,
      destName: getField(gschem,"destName").string.buildReadOnly(rawRec),
boxes: {rel: asMultipleRelField(getQueryableRelField(gschem,"boxes", boxRecordBuilder, rawRec)), scalar: getField(gschem,"boxes").string.buildReadOnly(rawRec)},
currentMaximalBoxNumber: getField(gschem,"currentMaximalBoxNumber").int.buildReadOnly(rawRec),
destinationPrefix: getField(gschem,"destinationPrefix").string.buildReadWrite(rawRec),
boxOffset: getField(gschem,"boxOffset").int.buildReadWrite(rawRec),
isSerialBox: getField(gschem,"isSerialBox").bool.buildReadWrite(rawRec),
    } and boxRecordBuilder: (genericSchema, airtableRawRecord) => boxRecord = (gschem, rawRec) => {
      id: rawRec.id,
      boxName: getField(gschem,"boxName").string.buildReadOnly(rawRec),
boxLines: {rel: asMultipleRelField(getQueryableRelField(gschem,"boxLines", boxLineRecordBuilder, rawRec)), scalar: getField(gschem,"boxLines").string.buildReadOnly(rawRec)},
boxDest: {rel: asSingleRelField(getQueryableRelField(gschem,"boxDest", boxDestinationRecordBuilder, rawRec)), scalar: getField(gschem,"boxDest").string.buildReadOnly(rawRec)},
boxNumberOnly: getField(gschem,"boxNumberOnly").int.buildReadWrite(rawRec),
isMaxBox: getField(gschem,"isMaxBox").intBool.buildReadOnly(rawRec),
isPenultimateBox: getField(gschem,"isPenultimateBox").intBool.buildReadOnly(rawRec),
isEmpty: getField(gschem,"isEmpty").intBool.buildReadOnly(rawRec),
boxNotes: getField(gschem,"boxNotes").string.buildReadWrite(rawRec),
    } and boxLineRecordBuilder: (genericSchema, airtableRawRecord) => boxLineRecord = (gschem, rawRec) => {
      id: rawRec.id,
      name: getField(gschem,"name").string.buildReadOnly(rawRec),
boxRecord: {rel: asSingleRelField(getQueryableRelField(gschem,"boxRecord", boxRecordBuilder, rawRec)), scalar: getField(gschem,"boxRecord").string.buildReadOnly(rawRec)},
boxLineSku: {rel: asSingleRelField(getQueryableRelField(gschem,"boxLineSku", skuRecordBuilder, rawRec)), scalar: getField(gschem,"boxLineSku").string.buildReadOnly(rawRec)},
boxLineSkuOrder: {rel: asSingleRelField(getQueryableRelField(gschem,"boxLineSkuOrder", skuOrderRecordBuilder, rawRec)), scalar: getField(gschem,"boxLineSkuOrder").string.buildReadOnly(rawRec)},
qty: getField(gschem,"qty").int.buildReadWrite(rawRec),
    }

let buildSchema: array<airtableTableDef> => schema = tdefs => {
  let base = useBase()
  switch(dereferenceGenericSchema(base,tdefs)) {
    | Error(errstr) => Js.Exn.raiseError(errstr)
    | Ok(gschem) => {
      skuOrderTracking: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"skuOrderTracking",skuOrderTrackingRecordBuilder)),
        crud: getTableRecordOperations(gschem,"skuOrderTracking"),
        hasTrackingNumbersView: asMultipleRelField(getQueryableTableOrView(gschem,"hasTrackingNumbersView",skuOrderTrackingRecordBuilder)),
        trackingNumberField: getField(gschem,"trackingNumber").string.tableSchemaField,
trackingLinkField: getField(gschem,"trackingLink").string.tableSchemaField,
skuOrdersField: getField(gschem,"skuOrders").relMulti.tableSchemaField,
isReceivedField: getField(gschem,"isReceived").intBool.tableSchemaField,
shipDateField: getField(gschem,"shipDate").momentOption.tableSchemaField,
receivedTimeField: getField(gschem,"receivedTime").momentOption.tableSchemaField,
jocoNotesField: getField(gschem,"jocoNotes").string.tableSchemaField,
warehouseNotesField: getField(gschem,"warehouseNotes").string.tableSchemaField,
    },
skuOrder: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"skuOrder",skuOrderRecordBuilder)),
        crud: getTableRecordOperations(gschem,"skuOrder"),
        
        orderNameField: getField(gschem,"orderName").string.tableSchemaField,
trackingRecordField: getField(gschem,"trackingRecord").relSingle.tableSchemaField,
skuOrderSkuField: getField(gschem,"skuOrderSku").relSingle.tableSchemaField,
skuOrderBoxLinesField: getField(gschem,"skuOrderBoxLines").relMulti.tableSchemaField,
skuOrderBoxDestField: getField(gschem,"skuOrderBoxDest").relSingle.tableSchemaField,
quantityExpectedField: getField(gschem,"quantityExpected").int.tableSchemaField,
quantityReceivedField: getField(gschem,"quantityReceived").intOpt.tableSchemaField,
quantityPackedField: getField(gschem,"quantityPacked").int.tableSchemaField,
boxedCheckboxField: getField(gschem,"boxedCheckbox").bool.tableSchemaField,
externalProductNameField: getField(gschem,"externalProductName").string.tableSchemaField,
skuOrderIsReceivedField: getField(gschem,"skuOrderIsReceived").bool.tableSchemaField,
receivingNotesField: getField(gschem,"receivingNotes").string.tableSchemaField,
    },
sku: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"sku",skuRecordBuilder)),
        crud: getTableRecordOperations(gschem,"sku"),
        
        skuNameField: getField(gschem,"skuName").string.tableSchemaField,
serialNumberField: getField(gschem,"serialNumber").string.tableSchemaField,
isSerialRequiredField: getField(gschem,"isSerialRequired").intBool.tableSchemaField,
lifetimeOrderQtyField: getField(gschem,"lifetimeOrderQty").int.tableSchemaField,
skuAttachmentsField: getField(gschem,"skuAttachments").attachments.tableSchemaField,
    },
boxDestination: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"boxDestination",boxDestinationRecordBuilder)),
        crud: getTableRecordOperations(gschem,"boxDestination"),
        
        destNameField: getField(gschem,"destName").string.tableSchemaField,
boxesField: getField(gschem,"boxes").relMulti.tableSchemaField,
currentMaximalBoxNumberField: getField(gschem,"currentMaximalBoxNumber").int.tableSchemaField,
destinationPrefixField: getField(gschem,"destinationPrefix").string.tableSchemaField,
boxOffsetField: getField(gschem,"boxOffset").int.tableSchemaField,
isSerialBoxField: getField(gschem,"isSerialBox").bool.tableSchemaField,
    },
box: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"box",boxRecordBuilder)),
        crud: getTableRecordOperations(gschem,"box"),
        
        boxNameField: getField(gschem,"boxName").string.tableSchemaField,
boxLinesField: getField(gschem,"boxLines").relMulti.tableSchemaField,
boxDestField: getField(gschem,"boxDest").relSingle.tableSchemaField,
boxNumberOnlyField: getField(gschem,"boxNumberOnly").int.tableSchemaField,
isMaxBoxField: getField(gschem,"isMaxBox").intBool.tableSchemaField,
isPenultimateBoxField: getField(gschem,"isPenultimateBox").intBool.tableSchemaField,
isEmptyField: getField(gschem,"isEmpty").intBool.tableSchemaField,
boxNotesField: getField(gschem,"boxNotes").string.tableSchemaField,
    },
boxLine: {
        rel: asMultipleRelField(getQueryableTableOrView(gschem,"boxLine",boxLineRecordBuilder)),
        crud: getTableRecordOperations(gschem,"boxLine"),
        
        nameField: getField(gschem,"name").string.tableSchemaField,
boxRecordField: getField(gschem,"boxRecord").relSingle.tableSchemaField,
boxLineSkuField: getField(gschem,"boxLineSku").relSingle.tableSchemaField,
boxLineSkuOrderField: getField(gschem,"boxLineSkuOrder").relSingle.tableSchemaField,
qtyField: getField(gschem,"qty").int.tableSchemaField,
    },
    }
  }
}
  
