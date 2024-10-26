switch ReactDOM.querySelector("#root") {
| Some(rootElement) => {
    let root = ReactDOM.Client.createRoot(rootElement)
    root->ReactDOM.Client.Root.render(<NotePad />)
  }
| None => Js.Console.error("Root element not found")
}