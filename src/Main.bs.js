// Generated by ReScript, PLEASE EDIT WITH CARE

import * as NotePad from "./NotePad.bs.js";
import * as Client from "react-dom/client";
import * as JsxRuntime from "react/jsx-runtime";

var rootElement = document.querySelector("#root");

if (rootElement == null) {
  console.error("Root element not found");
} else {
  var root = Client.createRoot(rootElement);
  root.render(JsxRuntime.jsx(NotePad.make, {}));
}

export {
  
}
/* rootElement Not a pure module */
