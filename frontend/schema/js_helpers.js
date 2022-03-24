let ui = require('@airtable/blocks/ui')
let moment = require('moment')

let useRecords = ui.useRecords

function prepBareString (record, field) {
  return record.getCellValueAsString(field)
}

function prepStringOption (record, field) {
  let v = record.getCellValueAsString(field)
  if (v && v.trim().length > 0) {
    return v
  }

  return undefined
}

function prepIntOption (record, field) {
  let v = parseInt(record.getCellValueAsString(field))
  // we go the long way here because formula fields can return a buncha shit

  if (Number.isNaN(v)) {
    return undefined
  }

  return v
}
function prepInt (record, field) {
  let v = prepIntOption(record, field)

  if (v === undefined) {
    console.error(
      `requested field cannot be parsed as int, returning 0 [fieldname:${field.name},recordname:${record.name},val: ${v}]`
    )
    return 0
  }

  return v
}

function prepBool (record, field) {
  let v = record.getCellValue(field)
  return !!v
}

function prepIntAsBool (record, field) {
  let v = prepInt(record, field)
  if (v < 0 || v > 1) {
    console.error(
      `requested field is an int bool, but has a value that's neither 0 or 1, returning false [fieldname:${field.name},recordname:${record.name},val: ${v}]`
    )
    return false
  }

  return !!v
}

function prepMomentOption (record, field) {
  let v = record.getCellValueAsString(field)
  let vm = moment(v)

  if (!vm.isValid()) {
    if (v.trim() !== '') {
      // if the cell is blank we don't care... it's just empty
      // this is NOT a type error, it's a None option
      // BUT if the moment is invalid for another reason then...
      // type error
      console.error(
        `requested field is a moment, but moment doesn't think so [fieldname:${field.name},recordname:${record.name},val: ${v}]`
      )
    }
    return undefined
  }
  return vm
}

function prepMultipleAttachments (record, field) {
  // per https://airtable.com/developers/apps/api/FieldType#MULTIPLE_ATTACHMENTS
  let arr = record.getCellValue(field)
  let toOpt = val => (val ? val : undefined)
  let mapThumb = th => ({
    thumbnailUrl: th.url,
    widthPx: th.width,
    heightPx: th.height
  })

  return !Array.isArray(arr)
    ? []
    : arr.map(att => {
        // change some field names to match the ones we have
        // and map all the nullish stuff to undefined so it's an option

        let hasThumbs = !!att.thumbnails
        let hasSmallThumbs = hasThumbs && !!att.thumbnails.small
        let hasLargeThumbs = hasThumbs && !!att.thumbnails.large
        let hasFullThumbs = hasThumbs && !!att.thumbnails.full

        return {
          id: att.id,
          url: att.url,
          filename: att.filename,
          contentType: toOpt(att.type),
          sizeInBytes: toOpt(att.size),
          thumbnail: {
            small: hasSmallThumbs ? mapThumb(att.thumbnails.small) : undefined,
            large: hasLargeThumbs ? mapThumb(att.thumbnails.large) : undefined,
            full: hasFullThumbs ? mapThumb(att.thumbnails.full) : undefined
          }
        }
      })
}

function prepRelFieldQueryResult (record, field, fetchfields, sortsArr) {
  return record.selectLinkedRecordsFromCell(field, {
    fields: fetchfields,
    sorts: sortsArr
  })
}

function selectRecordsFromTableOrView (tableOrView, fetchfields, sortsArr) {
  return tableOrView.selectRecords({
    fields: fetchfields,
    sorts: sortsArr
  })
}

function buildAirtableObjectMap (arrTuple) {
  // we pass in an array of tuples, which are themselves arrays
  // so it's an array of 2 el arrays
  // the first is the raw field and the second is the raw value
  let obj = {}
  arrTuple.forEach(el => (obj[el[0].id] = el[1]))
  console.log(arrTuple, obj)
  return obj
}

exports.prepBareString = prepBareString
exports.prepStringOption = prepStringOption
exports.prepInt = prepInt
exports.prepIntOption = prepIntOption
exports.prepBool = prepBool
exports.prepIntAsBool = prepIntAsBool
exports.prepMomentOption = prepMomentOption
exports.prepMultipleAttachments = prepMultipleAttachments
exports.prepRelFieldQueryResult = prepRelFieldQueryResult
exports.selectRecordsFromTableOrView = selectRecordsFromTableOrView
exports.buildAirtableObjectMap = buildAirtableObjectMap
exports.moment = moment
