type tableColumnDef<'a> = {
  header: string,
  accessor: 'a => React.element,
  tdStyle: ReactDOM.Style.t,
}

@react.component
let make = (~columnDefs: array<tableColumnDef<'a>>, ~elements: array<'a>, ~rowId: 'a => string) => {
  open Belt
  open Util
  let baseTdStyle = ReactDOM.Style.make(
    ~padding="5px",
    ~border="solid 1px black",
    ~borderCollapse="collapse",
    (),
  )
  <table style={ReactDOM.Style.make(~width="100%", ())->ReactDOM.Style.combine(baseTdStyle)}>
    <thead>
      <tr>
        {columnDefs->Array.map(def =>
          <th style={baseTdStyle} key={def.header}> {s(def.header)} </th>
        ) |> React.array}
      </tr>
    </thead>
    <tbody> {elements->Array.map(el => {
        <tr key={rowId(el)}> {columnDefs->Array.map(def => {
            <td
              key={`${rowId(el)}_${def.header}`}
              style={ReactDOM.Style.combine(def.tdStyle, baseTdStyle)}>
              {def.accessor(el)}
            </td>
          }) |> React.array} </tr>
      }) |> React.array} </tbody>
  </table>
}
