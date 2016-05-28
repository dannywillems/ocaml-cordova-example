include Makefile.conf

################################################################################
############################## Variables #######################################
##### You don't need to change it.
MLI_FILES					=	$(wildcard $(ML_DIRECTORY)/*.mli)
BYTE_FILES 					=	$(patsubst $(ML_DIRECTORY)/%.ml, $(ML_DIRECTORY)/%.byte, $(ML_FILES))
TMP_OUT_BYTECODE			=	$(ML_DIRECTORY)/out.byte
CC_CAML						=	ocamlc

ifeq ($(SYNTAX_EXTENSION),camlp4)
	BASIC_PACKAGE 	=	-package js_of_ocaml -package js_of_ocaml.syntax
	BASIC_SYNTAX	=	-syntax camlp4o
else
	BASIC_PACKAGE	=	-package js_of_ocaml -package js_of_ocaml.ppx
endif

ifeq ($(USE_GEN_JS_API) $(DEBUG),True True)
	CC_JS		= js_of_ocaml -o $(ML_JS_DIRECTORY)/$(ML_JS_OUTPUT_FILE) --pretty --debug-info +gen_js_api/ojs_runtime.js $(TMP_OUT_BYTECODE)
	CC_CAML		= ocamlc -g -no-check-prims
else ifeq ($(USE_GEN_JS_API) $(DEBUG),True False)
	CC_JS = js_of_ocaml -o $(ML_JS_DIRECTORY)/$(ML_JS_OUTPUT_FILE) +gen_js_api/ojs_runtime.js $(TMP_OUT_BYTECODE)
	CC_CAML		= ocamlc -no-check-prims
else ifeq ($(USE_GEN_JS_API) $(DEBUG),False True)
	CC_JS = js_of_ocaml -o $(ML_JS_DIRECTORY)/$(ML_JS_OUTPUT_FILE) --pretty --debug-info $(TMP_OUT_BYTECODE)
	CC_CAML		= ocamlc -g
else
	CC_JS = js_of_ocaml -o $(ML_JS_DIRECTORY)/$(ML_JS_OUTPUT_FILE) $(TMP_OUT_BYTECODE)
endif

CMO_FILES					=	$(patsubst $(ML_DIRECTORY)/%.ml, $(ML_DIRECTORY)/%.cmo, $(ML_FILES))
CMI_FILES					=	$(patsubst $(ML_DIRECTORY)/%.ml, $(ML_DIRECTORY)/%.cmi, $(ML_FILES))

ifeq ($(DEBUG),True)
	LESSC	= lessc
else
	LESSC	= lessc --clean-css
endif
################################################################################

################################################################################
################# Variables for binary/executables #############################
# TODO: Define variables for binary and executables to check if they exist. Use
# $(shell command -v COMMAND_NAME) and ifndef
################################################################################

################################################################################
###################################### Rules ###################################
.PHONY: clean js_of_ocaml css clean_js_of_ocaml clean_css re_css re_js_of_ocaml re prod re_prod init android init_dir init_dep

all: init_dir css js_of_ocaml $(PROD_DIRECTORY_LIST)

##### Compile bytecode to js
js_of_ocaml:
	mkdir -p $(ML_JS_DIRECTORY)
	ocamlfind $(CC_CAML) -I $(ML_DIRECTORY) -o $(TMP_OUT_BYTECODE) \
	$(BASIC_PACKAGE) $(CUSTOM_PACKAGE) $(BASIC_SYNTAX) $(CUSTOM_SYNTAX) \
	-linkpkg $(ML_FILES) $(MLI_FILES)
	$(CC_JS)

##### MINIFY CSS
css: clean_css_minify $(CSS_FILES)

$(CSS_DIR)/%.css: $(LESS_DIR)/%.less
ifeq ($(DEBUG),True)
		$(LESSC) $< $@
else
	    $(LESSC) $< >> $(CSS_MINIFY_OUTPUT)
endif

$(PROD_DIRECTORY)/%: $(DEV_DIRECTORY)/%
	$(RM) $@
	cp -r $< $@

##### Cordova rules
build_android: all
ifeq ($(DEBUG),False)
	@echo "-----> Build Android: release version"
	@cordova build android --release
	@echo "-----> Copy the apk into $(BUILD_DIRECTORY)/android"
	@cp platforms/android/build/outputs/apk/android-release-unsigned.apk $(BUILD_DIRECTORY)/android/$(BUILD_RELEASE_NAME_TEMPLATE).apk
else
	@echo "-----> Build Android: debug version"
	@cordova build android
	@echo "-----> Copy the apk into $(BUILD_DIRECTORY)/android"
	cp platforms/android/build/outputs/apk/android-debug.apk $(BUILD_DIRECTORY)/android/$(BUILD_NAME_TEMPLATE).apk
endif

install_android: build_android
ifeq ($(DEBUG),False)
	@echo "-----> Install release version on Android device. Be sure adb server is launched!"
	@adb install -r platforms/android/build/outputs/apk/android-release-unsigned.apk
else
	@echo "-----> Install debug version on Android device. Be sure adb server is launched!"
	@adb install -r platforms/android/build/outputs/apk/android-debug.apk
endif

run_android: all
	@echo "-----> Run the application on the connected device or in the emulator"
	@cordova run android

run_ios: all
	@echo "-----> Run the application on the connected device or in the emulator"
	@cordova run ios

build_ios: all
	@cordova build ios

add_android:
	@echo "-----> Add android platform. Be sure you installed the Android SDK!"
	@cordova platform add android

add_ios:
	@echo "-----> Add iOS platform. Be sure you installed the iOS SDK!"
	@cordova platform add ios

rm_android:
	@echo "-----> Remove Android platform."
	@cordova platform rm android

rm_ios:
	@echo "-----> Remove iOS platform."
	@cordova platform rm ios

##### clean
clean: clean_js_of_ocaml clean_css clean_css_minify
	@echo "-----> Remove production directory list"
	$(RM) -r $(PROD_DIRECTORY_LIST)
	@echo "-----> Clean cordova"
	@cordova clean

clean_js_of_ocaml:
	@echo "-----> Remove ml compiled file"
	$(RM) $(BYTE_FILES)
	$(RM) $(ML_JS_DIRECTORY)/$(ML_JS_OUTPUT_FILE)

clean_css_minify:
	@echo "-----> Remove CSS minified file"
	$(RM) $(CSS_MINIFY_OUTPUT)

clean_css:
	@echo "-----> Remove CSS files"
	$(RM) $(CSS_FILES)

##### re
re_css: clean_css css

re_js_of_ocaml: clean_js_of_ocaml js_of_ocaml

re: clean all

##### special rules for prod
prod:
	make DEBUG=False css
	make DEBUG=False js_of_ocaml

re_prod:
	make DEBUG=False re_css
	make DEBUG=False re_js_of_ocaml

##### Initialisation
init_dir:
	mkdir -p $(PROD_DIRECTORY) $(JS_OUTPUT_DIR) $(CSS_DIR) $(BUILD_DIRECTORY)/android $(BUILD_DIRECTORY)/ios

init_plugins: $(PLUGINS)

$(PLUGINS):
	cordova plugin add $@

init_opam:
	opam install $(OPAM_PKG)

init: init_dir init_opam init_plugins
	mkdir -p hooks
