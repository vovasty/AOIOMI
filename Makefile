BUILD_DIR=.build/archive
ARCHIVE_PATH=$(BUILD_DIR)/app.xcarchive
APP_PATH=$(BUILD_DIR)/CoupangMobileApp.app
ZIP_PATH=$(BUILD_DIR)/CoupangMobileApp.zip
DERIVED_PATH=$(BUILD_DIR)/derived


.PHONY: all
all: archive

.PHONY: build
build:
	xcodebuild -workspace CoupangMobileApp.xcworkspace -config Release -scheme CoupangMobileApp -derivedDataPath $(DERIVED_PATH) -archivePath $(ARCHIVE_PATH) archive

.PHONY: export
export: build
	xcodebuild -archivePath $(ARCHIVE_PATH) -exportArchive -exportPath $(APP_PATH)  -exportOptionsPlist exportOptions.plist

.PHONY: archive
archive: export
	ditto -c -k --sequesterRsrc --keepParent $(APP_PATH) $(ZIP_PATH)	

.PHONY: clean
clean:
	rm -fr $(BUILD_DIR)