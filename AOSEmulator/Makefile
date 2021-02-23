export INSTALL_DIR = Sources/AOSEmulator/Resources/emulator
export JAVA_HOME = $(INSTALL_DIR)/jdk
export ANDROID_SDK_ROOT = $(INSTALL_DIR)/adk

ANDROID_SDK_TOOLS = $(ANDROID_SDK_ROOT)/cmdline-tools/tools/bin
ANDROID_PACKAGE="system-images;android-$(ANDROID_VERSION);$(ANDROID_TAG);$(ANDROID_PLATFORM)"

.PHONY: all
all: structure install-scripts install-jdk install-adk install-adk-components
	

.PHONY: install-jdk
install-jdk: structure
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	cp -r $(SOURCE_PACKAGES)/jdk "$(JAVA_HOME)"

.PHONY: structure
structure:
	mkdir -p "$(INSTALL_DIR)"
	
.PHONY: install-scripts
install-scripts: structure
ifndef ANDROID_VERSION
	$(error ANDROID_VERSION is not set)
endif
ifndef ANDROID_PLATFORM
	$(error ANDROID_PLATFORM is not set)
endif
ifndef ANDROID_TAG
	$(error ANDROID_TAG is not set)
endif
	echo ANDROID_VERSION=\"$(ANDROID_VERSION)\" > $(INSTALL_DIR)/env.sh
	echo ANDROID_PLATFORM=\"$(ANDROID_PLATFORM)\" >> $(INSTALL_DIR)/env.sh
	echo ANDROID_PACKAGE=\"$(ANDROID_PACKAGE)\" >> $(INSTALL_DIR)/env.sh
	echo ANDROID_TAG=\"$(ANDROID_TAG)\" >> $(INSTALL_DIR)/env.sh
	
.PHONY: install-adk
install-adk: structure
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	mkdir -p "$(ANDROID_SDK_ROOT)/cmdline-tools" && \
	cp -r $(SOURCE_PACKAGES)/cmdline-tools "$(ANDROID_SDK_ROOT)/cmdline-tools/tools"

.PHONY: install-adk install-jdk
install-adk-components: install-adk
ifndef ANDROID_VERSION
	$(error ANDROID_VERSION is not set)
endif
ifndef ANDROID_PLATFORM
	$(error ANDROID_PLATFORM is not set)
endif
	echo yes | $(ANDROID_SDK_TOOLS)/sdkmanager --channel=0 emulator "platform-tools" "platforms;android-$(ANDROID_VERSION)" && \
	echo yes | $(ANDROID_SDK_TOOLS)/sdkmanager --install $(ANDROID_PACKAGE)

.PHONY: install-gapps
install-gapps: structure
ifndef SOURCE_PACKAGES
	$(error SOURCE_PACKAGES is not set)
endif
	mkdir -p "$(INSTALL_DIR)/gapps"
	cp $(SOURCE_PACKAGES)/open_gapps*/Core/*  $(INSTALL_DIR)/gapps && \
	cd $(INSTALL_DIR)/gapps && \
	rm setup* && \
	lzip -d *.lz && \
	for f in $$(ls *.tar) ; do \
		tar -x --strip-components 2 -f $$f ; \
	done && \
	rm *.tar

.PHONY: clean
clean:
	rm -fr $(INSTALL_DIR)

.PHONY: clean
test:
	export INSTALL_DIR
	tests/test.sh
