let onload _ =
  let text = "version: " ^ (Js.to_string Cordova.cordova##version) ^
  "\nplatformId: " ^ (Js.to_string Cordova.cordova##platformId) ^
  "\nplatformVersion: " ^ (Js.to_string Cordova.cordova##platformVersion) in
  Dom_html.window##alert (Js.string text);
  Js._false

let _ = Dom_html.window##onload <- Dom_html.handler onload
