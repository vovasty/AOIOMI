export INSTALL_DIR = Sources/MITMProxy/Resources


.PHONY: bootstrap
bootstrap:
ifndef SOURCE_PACKAGES
    $(error SOURCE_PACKAGES is not set)
endif
	rm -f /tmp/mitm*
	tar -zxf $(SOURCE_PACKAGES)/mitmproxy-*-osx.tar.gz -C /tmp
	install /tmp/mitmweb "$(INSTALL_DIR)"/mitmweb

.PHONY: clean
clean:
	rm -f "$(INSTALL_DIR)"/mitmweb
