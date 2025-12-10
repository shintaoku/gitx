# GitX Makefile

CONFIGURATION ?= Debug
BUILD_DIR = build/$(CONFIGURATION)
APP = $(BUILD_DIR)/GitX.app

# Auto-detect OpenSSL path from Homebrew
OPENSSL_PREFIX = $(shell brew --prefix openssl@3)

# Architecture settings (Defaults to arm64 for Apple Silicon)
ARCHS ?= arm64
VALID_ARCHS ?= arm64 x86_64

.PHONY: all clean bootstrap libgit2 build run

all: build

# Clean the build directory
clean:
	rm -rf build
	xcodebuild -workspace GitX.xcodeproj/project.xcworkspace -scheme $(CONFIGURATION) clean

# Initialize submodules and dependencies
bootstrap:
	git submodule update --init --recursive
	# Note: This script might require sudo access to symlink tools into /usr/local
	cd objective-git && ./script/bootstrap

# Update/Build libgit2 (Objective-Git dependency)
libgit2:
	cd objective-git && ./script/update_libgit2

# Main build command
build: libgit2
	xcrun xcodebuild -scheme $(CONFIGURATION) \
		-workspace GitX.xcodeproj/project.xcworkspace \
		build \
		CONFIGURATION_BUILD_DIR=$(BUILD_DIR) \
		ARCHS=$(ARCHS) \
		"VALID_ARCHS=$(VALID_ARCHS)" \
		"LIBRARY_SEARCH_PATHS=\$$(inherited) $(OPENSSL_PREFIX)/lib"

# Run the application
run: build
	open $(APP)

