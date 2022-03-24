open Reducer
open PipelineDialog
open Util

@react.component
let make = (~state: Reducer.state, ~dispatch) => {
  open AirtableUI
  <div>
    <div> <Heading> {React.string("Tracking Number Search")} </Heading> </div>
    <div>
      <Input
        style={ReactDOM.Style.make(~width="333px", ~marginRight="15px", ())}
        value=state.searchString
        onChange={dispatch->onChangeHandler(s => UpdateSearchString(s))}
      />
      <CancelButton onClick={() => dispatch(UpdateSearchString(""))}>
        {`Clear Search!`->s}
      </CancelButton>
    </div>
  </div>
}
