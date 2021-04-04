export INSTALL_DIR = Sources/TranslatorAddon/Resources/python

.PHONY: bootstrap
bootstrap:
	swift build -c release --product Translator
	install .build/release/libTranslator.dylib "$(INSTALL_DIR)"

.PHONY: clean
clean:
	rm -f "$(INSTALL_DIR)"/libTranslator.dylib
	rm -fr .build
