/**
UI INTEGRATION
UI INTEGRATION
UI INTEGRATION
*/
module Input = {
  @bs.module("@airtable/blocks/ui") @react.component
  external make: (
    ~value: string,
    ~onChange: ReactEvent.Form.t => 'a,
    ~style: ReactDOM.Style.t,
  ) => React.element = "Input"
}

module Dialog = {
  @bs.module("@airtable/blocks/ui") @react.component
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
  @bs.module("./AirtableUI_helpers") @react.component
  external make: (~onClose: unit => 'a, ~children: React.element) => React.element = "JoCoDialog"
}*/

module DialogCloseButton = {
  @bs.module("./AirtableUI_helpers") @react.component
  external make: unit => React.element = "DialogCloseButton"
}

module Heading = {
  @bs.module("@airtable/blocks/ui") @react.component
  external make: (
    ~style: ReactDOM.Style.t=?,
    ~size: string=?,
    ~children: React.element,
  ) => React.element = "Heading"
}

module Button = {
  @bs.module("@airtable/blocks/ui") @react.component
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
