# OCaml-cordova-example

This is an example of the binding to the *cordova* object. See the binding
[here](https://github.com/dannywillems/ocaml-cordova)

For the moment, basic binding to
* platformId
* platformVersion
* version

![screenshot1_android.png](github_res/screenshot1_android.png) ![screenshot1_ios.png](github_res/screenshot1_ios.png)

## What is cordova ?

[Wikipedia](https://en.wikipedia.org/wiki/Apache_Cordova):
```
Apache Cordova enables software programmers to build applications for mobile
devices using CSS3, HTML5, and JavaScript instead of relying on
platform-specific APIs like those in Android, iOS, or Windows Phone.[5] It
enables wrapping up of CSS, HTML, and JavaScript code depending upon the
platform of the device. It extends the features of HTML and JavaScript to work
with the device. The resulting applications are hybrid, meaning that they are
neither truly native mobile application (because all layout rendering is done
via Web views instead of the platform's native UI framework) nor purely
Web-based (because they are not just Web apps, but are packaged as apps for
distribution and have access to native device APIs).
```

## Using js_of_ocaml to develop in OCaml on mobile

js_of_ocaml allows you to compile ml files in javascript files. With this
compiler, you can use OCaml to develop hybrid mobile application.

You need to install [ocaml](http://ocaml.org/), [opam](https://opam.ocaml.org/)
and js_of_ocaml (with opam). You also need to install cordova (see
[here](https://cordova.apache.org/docs/en/4.0.0/guide/cli/)).

## Project structure

* www (not present if you just cloned this repo)
	Cordova copies this directory in the built archive. To avoid to have some
	files you don't want in the archive, the Makefile allows you to develop in
	another directory (default = app) which you can change in the Makefile (see
	below).

* app:
	The main directory. **You write your code here**.
	At the root, you have the index.html file. You also have a ml directory
	which you can put your ml files in. If you decide to write your OCaml code
	in another directory, you have to modify the ML_DIRECTORY variable in the
	Makefile.

## How does the Makefile work ?

I wrote a Makefile to automate some tasks such as compile ml files, compile the
archive for the platform, compile less files, etc.

The Makefile configuration depends on your workflow and project structure.
Here some variables:

### For the application
* PROJECT_NAME: the project name. It's used to rename built apk or ipa archive.
* VERSION: application version. Also used to rename build apk or ipa archive.

* DEV_DIRECTORY: the Makefile allows you to develop your cordova application
  in another directory than the default www. It's more secure because when you
  build the apk or ipa archive, cordova copies all the files contained in the
  www directory. It's useful if you have some script or files you don't want to
  push but you uses in production (such as ml files).
* PROD_DIRECTORY: default = www. It's possible to change de default www cordova
  directory which is imported in the archive.

### About ml files

* ML_DIRECTORY: the directory containing your ml files.
* ML_FILES: your ml files. A wildcard isn't used because sometimes you don't
  want to build some test files. Default = $(DEV_DIRECTORY)/ml = app/ml
* MLI_FILES: your mli files.
* ML_JS_DIRECTORY: where the output js file must be put in.

* CUSTOM_PACKAGE/CUSTOM_SYNTAX: if you use additionnal syntax or package.

### LESS and CSS configuration.

Not useful here.

### Copied files and directories while the compilation

* DEV_DIRECTORY_LIST: While the compilation, files and directories must be
  copied in the PROD_DIRECTORY (ie www by default). Add directories and files
  you want to copy in the prod directory, ie files and directories you want to
  have in the archive.

### Build configuration

The Makefile allows you to keep old built archive.

* BUILD_DIRECTORY: the directory where you want to keep the archive. An android
  and ios subdirectory are created and the archive is copied in the
  appropriate directory.
* BUILD_NAME_TEMPLATE: the Makefile renames the built apk or ipa. You can choose
  the name template.
* BUILD_RELEASE_TEMPLATE: same as BUILD_NAME_TEMPLATE but for released archive.

### Rules

* all: default target. Compiles ml in js, copies the directories and files
  contained in the DEV_DIRECTORY_LIST and compiles less files.

**Be sure you have connected your phone**

* build_android/ios: build the apk. Calls *all* target first and copies the apk in
  the BUILD_DIRECTORY.
* install_android: install the apk on the phone.
* add/rm_android/ios: add/remove android/ios platform. Alias to *cordova platform add/rm
  android/ios*.

* clean: remove generated js and css files and calls *cordova clean*.
* clean_js_of_ocaml: remove generated js file from ml files. Remove cmi, cmo and
  byte files.
* clean_css: remove generated css files.

* init_plugins: initialize plugins you need. Empty for this project.
