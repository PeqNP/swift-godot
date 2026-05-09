SWIFT_PKG_DIR   := SwiftExtension
GODOT_BIN_DIR   := GodotProject/bin
LIB_NAME        := libMyExtension

.PHONY: all debug release clean

# Default: debug build
all: debug

debug:
	cd $(SWIFT_PKG_DIR) && swift build
	cp $(SWIFT_PKG_DIR)/.build/debug/$(LIB_NAME).dylib $(GODOT_BIN_DIR)/

release:
	cd $(SWIFT_PKG_DIR) && swift build -c release
	cp $(SWIFT_PKG_DIR)/.build/release/$(LIB_NAME).dylib $(GODOT_BIN_DIR)/

clean:
	cd $(SWIFT_PKG_DIR) && swift package clean
	rm -f $(GODOT_BIN_DIR)/$(LIB_NAME).dylib
