BUILD_DIR=.build
ARCHIVE_PATH=$(BUILD_DIR)/app.xcarchive
BUILDED_APP_PATH=$(ARCHIVE_PATH)/Products/Applications/CoupangMobileApp.app
ZIP_PATH=$(BUILD_DIR)/../CoupangMobileApp.zip
DERIVED_PATH=$(BUILD_DIR)/derived


.PHONY: all
all: archive

.PHONY: build
build:
	xcodebuild -project CoupangMobileApp.xcodeproj -config Release -scheme CoupangMobileApp -derivedDataPath $(DERIVED_PATH) -archivePath $(ARCHIVE_PATH) archive
	
.PHONY: export
export: build
	xcodebuild -archivePath "$(ARCHIVE_PATH)" -exportArchive -exportPath "$(APP_PATH)" -exportOptionsPlist exportOptions.plist

.PHONY: archive
archive: build
	ditto -c -k --sequesterRsrc --keepParent $(BUILDED_APP_PATH) $(ZIP_PATH)
	
.PHONY: aos
aos:
	 $(MAKE) -C AOSEmulator all

.PHONY: clean
clean:
	rm -fr $(BUILD_DIR)
	$(MAKE) -C AOSEmulator clean