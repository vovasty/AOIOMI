BUILD_DIR=.build
ARCHIVE_PATH=$(BUILD_DIR)/app.xcarchive
ZIP_PATH=$(BUILD_DIR)/../AOIOMI.zip
DERIVED_PATH=$(BUILD_DIR)/derived
EXPORT_PATH=$(BUILD_DIR)/export
EXPORTED_APP_PATH=$(EXPORT_PATH)/AOIOMI.app


.PHONY: all
all: clean bootstrap archive

.PHONY: build
build:
	xcodebuild -project AOIOMI.xcodeproj -config Release -scheme AOIOMI -derivedDataPath $(DERIVED_PATH) -archivePath $(ARCHIVE_PATH) archive
	
.PHONY: export
export: build
	xcodebuild -archivePath "$(ARCHIVE_PATH)" -exportArchive -exportPath "$(EXPORT_PATH)" -exportOptionsPlist ExportOptions.plist

.PHONY: archive
archive: export
	ditto -c -k --sequesterRsrc --keepParent $(EXPORTED_APP_PATH) $(ZIP_PATH)
	
.PHONY: bootstrap
bootstrap:
	 $(MAKE) -C AOSEmulatorRuntime bootstrap
	 $(MAKE) -C MITMProxy bootstrap
	 $(MAKE) -C Translator bootstrap

.PHONY: clean
clean:
	rm -fr $(BUILD_DIR)
	$(MAKE) -C AOSEmulatorRuntime clean
	$(MAKE) -C MITMProxy clean
	$(MAKE) -C Translator clean