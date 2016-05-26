let onload _ =
  let text =
    "version: " ^ Cordova.version ^
    "\nplatform id: " ^ Cordova.platform_id ^
    "\nplatform version: " ^ Cordova.platform_version in
  Jsoo_lib.alert text;
  Js._false

let _ =
  Jsoo_lib.onload onload
