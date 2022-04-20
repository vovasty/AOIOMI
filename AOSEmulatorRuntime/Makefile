export INSTALL_DIR = Sources/AOSEmulatorRuntime/Resources

.PHONY: bootstrap
bootstrap: guard-SOURCE_PACKAGES
	cp -r $(SOURCE_PACKAGES)/jdk "$(INSTALL_DIR)"/jdk
	install $(SOURCE_PACKAGES)/commandlinetools-mac*.zip "$(INSTALL_DIR)"/commandlinetools.zip

.PHONY: clean
clean:
	rm -rf "$(INSTALL_DIR)"/jdk
	rm -f "$(INSTALL_DIR)"/commandlinetools.zip

guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi
