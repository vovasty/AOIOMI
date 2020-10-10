export ROOT_DIR = ../Sources/AndroidEmulator/Resources/emulator
export JAVA_HOME = $(ROOT_DIR)/jdk
export ANDROID_SDK_ROOT = $(ROOT_DIR)/adk
ANDROID_SDK_TOOLS = $(ANDROID_SDK_ROOT)/cmdline-tools/tools/bin

.PHONY: all
all: structure install-jdk install-adk install-adk-components install-scripts install-gapps
	

.PHONY: install-jdk
install-jdk: structure
ifndef JDK
	$(error JDK is not set)
endif
	cp -r $(JDK) "$(JAVA_HOME)"

.PHONY: structure
structure:
	mkdir -p "$(ROOT_DIR)" "$(ROOT_DIR)/gapps"
	
.PHONY: install-scripts
install-scripts: structure
ifndef ANDROID_VERSION
	$(error ANDROID_VERSION is not set)
endif
	cp scripts/* $(ROOT_DIR)/ && \
	echo ANDROID_VERSION=$(ANDROID_VERSION) > $(ROOT_DIR)/env.sh
	
.PHONY: install-adk
install-adk: structure
ifndef ADK
	$(error ADK is not set)
endif
	mkdir -p "$(ANDROID_SDK_ROOT)/cmdline-tools" && \
	cp -r $(ADK) "$(ANDROID_SDK_ROOT)/cmdline-tools/tools"

.PHONY: install-adk install-jdk
install-adk-components: install-adk
ifndef ANDROID_VERSION
	$(error ANDROID_VERSION is not set)
endif
	echo yes | $(ANDROID_SDK_TOOLS)/sdkmanager --channel=0 emulator "platform-tools" "platforms;android-$(ANDROID_VERSION)" && \
	echo yes | $(ANDROID_SDK_TOOLS)/sdkmanager --install "system-images;android-$(ANDROID_VERSION);default;x86"

.PHONY: install-gapps
install-gapps: structure
ifndef GAPPS
	$(error GAPPS is not set)
endif
	cp $(GAPPS)/Core/*  $(ROOT_DIR)/gapps && \
	cd $(ROOT_DIR)/gapps && \
	rm setup* && \
	lzip -d *.lz && \
	for f in $$(ls *.tar) ; do \
		tar -x --strip-components 2 -f $$f ; \
	done && \
	rm *.tar

.PHONY: clean
clean:
	rm -fr $(ROOT_DIR)

.PHONY: clean
test:
	export ROOT_DIR
	tests/test.sh