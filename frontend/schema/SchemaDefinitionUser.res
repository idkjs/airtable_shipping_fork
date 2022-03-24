open SchemaDefinition

let rec skuOrdersTrackingTable: airtableTableDef = {
  resolutionMethod: ByName(`SKU Orders Tracking`),
  camelCaseTableName: `skuOrderTracking`,
  tableViews: [
    {
      resolutionMethod: ByName(`gtg_searchable_tracking_numbers`),
      camelCaseViewName: `hasTrackingNumbersView`,
    },
  ],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `trackingNumber`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`Tracking Link`),
      camelCaseFieldName: `trackingLink`,
      fieldValueType: FormulaRollupRO(BareString),
    },
    {
      resolutionMethod: ByName(`SKU Orders`),
      camelCaseFieldName: `skuOrders`,
      fieldValueType: RelFieldOption(skuOrdersTable, false, BareString),
    },
    {
      resolutionMethod: ByName(`gtg_was_tracking_number_received`),
      camelCaseFieldName: `isReceived`,
      fieldValueType: FormulaRollupRO(IntAsBool),
    },
    {
      resolutionMethod: ByName(`Date Shipped (JoCo)`),
      camelCaseFieldName: `shipDate`,
      fieldValueType: ScalarRW(MomentOption),
    },
    {
      resolutionMethod: ByName(`Date Received (GTG)`),
      camelCaseFieldName: `receivedTime`,
      fieldValueType: ScalarRW(MomentOption),
    },
    {
      resolutionMethod: ByName(`Receiving Notes (JoCo)`),
      camelCaseFieldName: `jocoNotes`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`Warehouse Notes (GTG)`),
      camelCaseFieldName: `warehouseNotes`,
      fieldValueType: ScalarRW(BareString),
    },
  ],
}
and skuOrdersTable: airtableTableDef = {
  resolutionMethod: ByName(`SKU Orders`),
  camelCaseTableName: `skuOrder`,
  tableViews: [],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `orderName`,
      fieldValueType: FormulaRollupRO(BareString),
    },
    {
      resolutionMethod: ByName(`Tracking Number`),
      camelCaseFieldName: `trackingRecord`,
      fieldValueType: RelFieldOption(skuOrdersTrackingTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`SKU`),
      camelCaseFieldName: `skuOrderSku`,
      fieldValueType: RelFieldOption(skusTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`Box Line(s)`),
      camelCaseFieldName: `skuOrderBoxLines`,
      fieldValueType: RelFieldOption(boxLinesTable, false, BareString),
    },
    {
      resolutionMethod: ByName(`Onboard Destination`),
      camelCaseFieldName: `skuOrderBoxDest`,
      fieldValueType: RelFieldOption(boxDestinationsTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`Quantity Ordered`),
      camelCaseFieldName: `quantityExpected`,
      fieldValueType: ScalarRW(Int),
    },
    {
      resolutionMethod: ByName(`Quantity Received`),
      camelCaseFieldName: `quantityReceived`,
      fieldValueType: ScalarRW(IntOption),
    },
    {
      resolutionMethod: ByName(`gtg_packed_qty`),
      camelCaseFieldName: `quantityPacked`,
      fieldValueType: FormulaRollupRO(Int),
    },
    {
      resolutionMethod: ByName(`Boxed?`),
      camelCaseFieldName: `boxedCheckbox`,
      fieldValueType: ScalarRW(Bool),
    },
    {
      resolutionMethod: ByName(`External Product Name`),
      camelCaseFieldName: `externalProductName`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`SKU Received?`),
      camelCaseFieldName: `skuOrderIsReceived`,
      fieldValueType: ScalarRW(Bool),
    },
    {
      resolutionMethod: ByName(`SKU Receiving Notes`),
      camelCaseFieldName: `receivingNotes`,
      fieldValueType: ScalarRW(BareString),
    },
  ],
}
and skusTable: airtableTableDef = {
  resolutionMethod: ByName(`SKUs`),
  camelCaseTableName: `sku`,
  tableViews: [],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `skuName`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`Serial Number`),
      camelCaseFieldName: `serialNumber`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`gtg_is_serial_required`),
      camelCaseFieldName: `isSerialRequired`,
      fieldValueType: FormulaRollupRO(IntAsBool),
    },
    {
      resolutionMethod: ByName(`gtg_lifetime_ordered_qty`),
      camelCaseFieldName: `lifetimeOrderQty`,
      fieldValueType: FormulaRollupRO(Int),
    },
    {
      resolutionMethod: ByName(`SKU Photograph/Attachments`),
      camelCaseFieldName: `skuAttachments`,
      fieldValueType: ScalarRW(Attachments),
    },
  ],
}
and boxDestinationsTable: airtableTableDef = {
  resolutionMethod: ByName(`Box Destinations`),
  camelCaseTableName: `boxDestination`,
  tableViews: [],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `destName`,
      fieldValueType: FormulaRollupRO(BareString),
    },
    {
      resolutionMethod: ByName(`Boxes`),
      camelCaseFieldName: `boxes`,
      fieldValueType: RelFieldOption(boxesTable, false, BareString),
    },
    {
      resolutionMethod: ByName(`Current Maximal Box #`),
      camelCaseFieldName: `currentMaximalBoxNumber`,
      fieldValueType: FormulaRollupRO(Int),
    },
    {
      resolutionMethod: ByName(`Prefix`),
      camelCaseFieldName: `destinationPrefix`,
      fieldValueType: ScalarRW(BareString),
    },
    {
      resolutionMethod: ByName(`Box Offset`),
      camelCaseFieldName: `boxOffset`,
      fieldValueType: ScalarRW(Int),
    },
    {
      resolutionMethod: ByName(`Serial Box?`),
      camelCaseFieldName: `isSerialBox`,
      fieldValueType: ScalarRW(Bool),
    },
  ],
}
and boxesTable: airtableTableDef = {
  resolutionMethod: ByName(`Boxes`),
  camelCaseTableName: `box`,
  tableViews: [],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `boxName`,
      fieldValueType: FormulaRollupRO(BareString),
    },
    {
      resolutionMethod: ByName(`Constituent Box Lines`),
      camelCaseFieldName: `boxLines`,
      fieldValueType: RelFieldOption(boxLinesTable, false, BareString),
    },
    {
      resolutionMethod: ByName(`Onboard Destination`),
      camelCaseFieldName: `boxDest`,
      fieldValueType: RelFieldOption(boxDestinationsTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`# Only`),
      camelCaseFieldName: `boxNumberOnly`,
      fieldValueType: ScalarRW(Int),
    },
    {
      resolutionMethod: ByName(`gtg_is_max_box`),
      camelCaseFieldName: `isMaxBox`,
      fieldValueType: FormulaRollupRO(IntAsBool),
    },
    {
      resolutionMethod: ByName(`gtg_is_penultimate_box`),
      camelCaseFieldName: `isPenultimateBox`,
      fieldValueType: FormulaRollupRO(IntAsBool),
    },
    {
      resolutionMethod: ByName(`gtg_is_empty`),
      camelCaseFieldName: `isEmpty`,
      fieldValueType: FormulaRollupRO(IntAsBool),
    },
    {
      resolutionMethod: ByName(`Notes`),
      camelCaseFieldName: `boxNotes`,
      fieldValueType: ScalarRW(BareString),
    },
  ],
}
and boxLinesTable: airtableTableDef = {
  resolutionMethod: ByName(`Box Lines`),
  camelCaseTableName: `boxLine`,
  tableViews: [],
  tableFields: [
    {
      resolutionMethod: PrimaryField,
      camelCaseFieldName: `name`,
      fieldValueType: FormulaRollupRO(BareString),
    },
    {
      resolutionMethod: ByName(`Box #`),
      camelCaseFieldName: `boxRecord`,
      fieldValueType: RelFieldOption(boxesTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`SKU`),
      camelCaseFieldName: `boxLineSku`,
      fieldValueType: RelFieldOption(skusTable, true, BareString),
    },
    {
      resolutionMethod: ByName(`SKU Order`),
      camelCaseFieldName: `boxLineSkuOrder`,
      fieldValueType: RelFieldOption(skuOrdersTable, true, BareString),
    },
    {resolutionMethod: ByName(`SKU Qty`), camelCaseFieldName: `qty`, fieldValueType: ScalarRW(Int)},
  ],
}

let allTables = [
  skuOrdersTrackingTable,
  skuOrdersTable,
  skusTable,
  boxDestinationsTable,
  boxesTable,
  boxLinesTable,
]
