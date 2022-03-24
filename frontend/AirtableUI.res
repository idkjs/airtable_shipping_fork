/**
UI INTEGRATION
UI INTEGRATION
UI INTEGRATION
*/
module Input = {
  @module("@airtable/blocks/ui") @react.component
  external make: (
    ~value: string,
    ~onChange: ReactEvent.Form.t => 'a,
    ~style: ReactDOM.Style.t,
  ) => React.element = "Input"
}

module Dialog = {
  @module("@airtable/blocks/ui") @react.component
  external make: (
    ~onClose: unit => 'a,
    ~children: React.element,
    ~width: int,
    ~paddingTop: string,
    ~paddingLeft: string,
    ~paddingRight: string,
    ~paddingBottom: string,
  ) => React.element = "Dialog"
}

/*
module JoCoDialog = {
  @module("./AirtableUI_helpers") @react.component
  external make: (~onClose: unit => 'a, ~children: React.element) => React.element = "JoCoDialog"
}*/

module DialogCloseButton = {
  @module("./AirtableUI_helpers") @react.component
  external make: unit => React.element = "DialogCloseButton"
}

module Heading = {
  @module("@airtable/blocks/ui") @react.component
  external make: (
    ~style: ReactDOM.Style.t=?,
    ~size: string=?,
    ~children: React.element,
  ) => React.element = "Heading"
}

module Button = {
  @module("@airtable/blocks/ui") @react.component
  external make: (
    ~children: React.element,
    ~icon: string,
    ~variant: string,
    ~size: string,
    ~onClick: unit => _,
    ~style: ReactDOM.Style.t=?,
    ~disabled: bool=?,
  ) => React.element = "Button"
}
