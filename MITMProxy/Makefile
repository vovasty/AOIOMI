export INSTALL_DIR = Sources/MITMProxy/Resources


.PHONY: bootstrap
bootstrap: guard-SOURCE_PACKAGES
	rm -f /tmp/mitm*
	tar -zxf $(SOURCE_PACKAGES)/mitmproxy-*-osx.tar.gz -C /tmp
	install /tmp/mitmweb "$(INSTALL_DIR)"/mitmweb

.PHONY: clean
clean:
	rm -f "$(INSTALL_DIR)"/mitmweb

guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi
