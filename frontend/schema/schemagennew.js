// needed or a pulled in airtable lib crashes
global.window = 'beep'

/*
// this was originally output by the below in a .res file, added the console.log

export default = Airtable.outputEntireSchemaAsString(SchemaDef.allTables)
*/

var gschem = require('./GenericSchema.bs.js')
var schdef = require('./SchemaDefinitionUser.bs.js')

var $$default = console.log(
  gschem.codeGenSchema(gschem.getSchemaMergeVars(schdef.allTables))
)

exports.$$default = $$default
exports.default = $$default
exports.__esModule = true
/*  Not a pure module */
