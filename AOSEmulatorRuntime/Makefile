export INSTALL_DIR = Sources/AOSEmulatorRuntime/Resources

.PHONY: bootstrap
bootstrap:
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	cp -r $(SOURCE_PACKAGES)/jdk "$(INSTALL_DIR)"/jdk
	install $(SOURCE_PACKAGES)/commandlinetools-mac*.zip "$(INSTALL_DIR)"/commandlinetools.zip

.PHONY: clean
clean:
	rm -rf "$(INSTALL_DIR)"/jdk
	rm -f "$(INSTALL_DIR)"/commandlinetools.zip
