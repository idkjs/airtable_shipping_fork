@bs.module("@airtable/blocks/ui")
external initializeBlock: (_ => React.element) => _ = "initializeBlock"

initializeBlock(() => <App />)
