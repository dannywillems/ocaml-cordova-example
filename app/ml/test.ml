let onload _ =
  Dom_html.window##alert (Cordova.cordova##version);
  Dom_html.window##alert (Cordova.cordova##platformId);
  Dom_html.window##alert (Cordova.cordova##platformVersion);
  Js._false

let _ = Dom_html.window##onload <- Dom_html.handler onload
