export INSTALL_DIR = Sources/TranslatorAddon/Resources/translatoraddon

.PHONY: bootstrap
bootstrap:
	swift build -c release --product Translator --package-path ../Translator
	install ../Translator/.build/release/libTranslator.dylib "$(INSTALL_DIR)"

.PHONY: clean
clean:
	rm -f "$(INSTALL_DIR)"/libTranslator.dylib
	rm -fr ../Translator/.build
