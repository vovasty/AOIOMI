export INSTALL_DIR = Sources/AOSEmulatorRuntime/Resources

.PHONY: all
all:
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	cp -r $(SOURCE_PACKAGES)/jdk "$(INSTALL_DIR)"/jdk
	install $(SOURCE_PACKAGES)/commandlinetools-mac*.zip "$(INSTALL_DIR)"/commandlinetools.zip
