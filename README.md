# godot-swift

A barebones Godot 4 project with a Swift GDExtension, powered by [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot).

## Project layout

```
godot-swift/
├── GodotProject/               # Open this folder in Godot 4
│   ├── project.godot
│   ├── MyExtension.gdextension # Tells Godot where to find the library
│   └── bin/                    # Built .dylib lands here after `make`
└── SwiftExtension/             # Swift Package (your extension code)
    ├── Package.swift
    └── Sources/MyExtension/
        └── MyExtension.swift   # SpinningCube demo node
```

## Requirements

- [Godot 4.4](https://godotengine.org/download/)
- Xcode 15+ / Swift 5.9+

## Getting started

### 1. Build the Swift extension

```bash
make          # debug build
# or
make release  # optimised build
```

This compiles the Swift package and copies `libMyExtension.dylib` into `GodotProject/bin/`.

### 2. Open the Godot project

Open `GodotProject/` in Godot 4. Godot will automatically load `MyExtension.gdextension` and register the `SpinningCube` node type.

### 3. Use your Swift node

In any 3D scene, add a child node and search for **SpinningCube** — it will appear under **Node3D**. It will create a spinning box at runtime.

## Adding your own Swift nodes

1. Create a new Swift file under `SwiftExtension/Sources/MyExtension/`.
2. Annotate your class with `@Godot` and subclass a Godot base type.
3. Add the new type to the `#initSwiftExtension` call in `MyExtension.swift`.
4. Run `make` and restart/reload the Godot editor.

## Rebuilding without restarting Godot

Use **Project > Reload Current Project** in the Godot editor after running `make` to pick up the updated library.

## Debugging in Xcode

Xcode can attach its debugger to a running Godot process so you can set Swift breakpoints in your extension.

### One-time setup: re-sign Godot

The official Godot binary is signed without the `com.apple.security.get-task-allow` entitlement, which macOS requires before an external debugger can attach. Re-sign it once with an ad-hoc signature that includes that entitlement:

```bash
# Clear any Gatekeeper quarantine flags first
xattr -cr /Applications/Godot.app

# Re-sign with the debug entitlement
codesign \
  --sign - \
  --entitlements godot-debug.entitlements \
  --force \
  --deep \
  /Applications/Godot.app
```

The `godot-debug.entitlements` file in the repo root contains the required entitlement. You will need to repeat this step after every Godot update.

### Fix "Cannot find X in scope" errors in Xcode

Xcode's indexer needs to build the package itself before it can resolve SwiftGodot types:

1. Open the Swift package in Xcode: `xed SwiftExtension`
2. Build with **⌘B**.
3. Open the **Issue Navigator** (**⌘5**). At the bottom you will see a prompt to **Trust & Enable** the SwiftGodot macro/plugin. Click it — Xcode may ask you to do this **twice** (once for each plugin SwiftGodot ships).
4. Once all libraries are trusted and enabled, Xcode will complete the build and all "Cannot find X in scope" errors will disappear.

### Attaching to a running game

1. Run `make` to build the debug `.dylib`.
2. Open `GodotProject/` in Godot and press **Run** (F5).
3. In Xcode, open the Swift package: `xed SwiftExtension`
4. Set any breakpoints you want in your Swift source files.
5. In the menu bar choose **Debug › Attach to Process by PID or Name…**, type `Godot`, and click **Attach**.

Xcode will attach to the Godot process and stop at your Swift breakpoints.
