export INSTALL_DIR = Sources/MITMProxy/Resources

.PHONY: bootstrap
bootstrap: install_translator
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	rm -f /tmp/mitm*
	tar -zxf $(SOURCE_PACKAGES)/mitmproxy-*-osx.tar.gz -C /tmp
	install /tmp/mitmweb "$(INSTALL_DIR)"/mitmproxy/mitmweb

.PHONY: install_translator
install_translator:
	swift build -c release --package-path ../Translator/
	install ../Translator/.build/release/libTranslator.dylib "$(INSTALL_DIR)"/lib

.PHONY: clean
clean:
	rm -fr ../Translator/.build
	rm -f "$(INSTALL_DIR)"/lib/libTranslator.dylib
	rm -f "$(INSTALL_DIR)"/mitmproxy/mitmweb
