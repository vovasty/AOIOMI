# AndroidEmulator

## Installation
* create `aos` directory
* Download `gapps pico 9.0 x86_64` from https://opengapps.org and unpack it into `aos`
* Download `commandlinetools-mac` from https://developer.android.com/studio#command-tools and unpack it into `aos`
* Get somewhere jdk and copy into `aos` with nam jdk
* run `make ANDROID_VERSION=28 ANDROID_PLATFORM=x86_64 SOURCE_PACKAGES=~/Downloads/aos DATA_ROOT=~/Library/Application\ Support/com.coupang.CoupangMobileApp ANDROID_TAG=google_apis clean all`

