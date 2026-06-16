# godot-swift

A barebones Godot 4 project with a Swift GDExtension, powered by [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot).

## Repo root vs Godot project folder

Run `make` commands from this repo root, where the `Makefile` lives. Open `GodotProject/` in Godot; it is the Godot project folder inside the larger SwiftGodot template repo.

## Create a new project

Use the scaffold script from this template repo:

```bash
scripts/create_project.sh --name MySwiftProject --dest ../MySwiftProject
cd ../MySwiftProject
make
make verify
open MySwiftProject.xcodeproj
```

In Xcode, select the shared `MySwiftProject-Godot` scheme and press **Cmd-R** to build the Swift extension, prepare a debug-signed Godot copy, and run the Godot project under Xcode's debugger.
If Xcode completion, symbol search, or option-click docs look incomplete after a fresh checkout, select the `MySwiftProject` Swift package scheme and build it once, then switch back to `MySwiftProject-Godot`.

See [TEMPLATE_USAGE.md](TEMPLATE_USAGE.md) for more scaffold options, including creating a project from an explicit local template path or git URL.

## Project layout

```
godot-swift/
├── MyExtension.xcodeproj       # Xcode wrapper plus Swift package reference
├── .gitignore                  # Ignored Swift, Godot, Xcode, and profiling output
├── GodotProject/               # Open this folder in Godot 4
│   ├── project.godot
│   ├── MyExtension.gdextension # Tells Godot where to find the library
│   └── bin/                    # Built .dylib lands here after `make`
└── SwiftExtension/             # Swift Package (your extension code)
    ├── Package.swift
    └── Sources/MyExtension/
        └── MyExtension.swift   # SpinningCube demo node
```

Generated projects keep the same `.gitignore`, so SwiftPM build folders, copied dylibs, Godot editor caches, Xcode user state, `.DS_Store`, and `*.profraw` profiling files stay out of source control. The Xcode project intentionally focuses on the Swift package, tests, scripts, and docs; edit Godot scenes and project files from Godot itself.

## Requirements

- [Godot 4.6](https://godotengine.org/download/) has been verified with this project. SwiftGodot's upstream README currently describes Godot 4.4 support, so prefer the version recorded in `GodotProject/project.godot` unless you are intentionally testing another Godot release.
- Xcode / Swift toolchain. This repo was verified with Swift 6.3.1, while the extension package itself declares Swift tools 5.9.

## Build and run this project

### 1. Build the Swift extension

```bash
make          # debug build
# or
make release  # optimised build
```

This compiles the Swift package and copies `libMyExtension.dylib` into `GodotProject/bin/`.
The build also copies SwiftGodot's runtime dylib, `libSwiftGodot.dylib`, which `libMyExtension.dylib` loads at runtime.
Build output is quiet by default; use `make VERBOSE=1` to show the full SwiftPM output.
The first build can still take a while because SwiftPM compiles SwiftGodot, SwiftSyntax, macros, and generated Godot bindings. Generated projects do not copy `.build`; SwiftPM will reuse its normal dependency caches where it safely can.
The Makefile uses `SWIFT_BIN` to pick a Swift CLI, preferring `~/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift` or Swiftly's `~/.swiftly/bin/swift` when available. Run `make toolchain` to see the selected compiler, or pass `SWIFT_BIN=/path/to/swift` if needed.

After building, you can verify that the copied dylibs and GDExtension metadata agree:

```bash
make verify
```

`make verify` also checks `GodotProject/.godot/extension_list.cfg`, which is intentionally kept in the repo so Godot loads `MyExtension.gdextension` from a clean checkout. Other `.godot` editor/cache files remain ignored.

`make doctor` is also available as an alias for `make verify`.

To list the available Makefile commands:

```bash
make help
```

To remove only the copied dylibs from `GodotProject/bin/` without clearing SwiftPM's build cache:

```bash
make clean-bin
```

To open the project with the default macOS Godot app path:

```bash
make open
```

If Godot is installed somewhere else, pass its executable path:

```bash
make open GODOT_BIN=/path/to/Godot
```

### Xcode workflow

Open `MyExtension.xcodeproj` in Xcode. The project references `SwiftExtension/` as a local Swift package so Xcode has a real SwiftPM graph for indexing, completion, symbol search, and option-click documentation.

Use the shared `MyExtension-Godot` scheme for running the game:

- **Cmd-B** runs the external build target, which invokes `make debug verify`.
- **Cmd-R** builds, runs `make prepare-godot-debug`, and launches `GodotProject/` through Xcode's LLDB launcher.
- **Cmd-U** runs the native `MyExtensionTests` XCTest target without running the Godot Makefile target first.

After a fresh checkout, package reset, or DerivedData clear, select the `MyExtension` Swift package scheme and build it once. That lets Xcode run SwiftGodot's package plugins and generate the API surface SourceKit needs for indexing. Then switch back to `MyExtension-Godot` for normal Godot debugging.

`make prepare-godot-debug` copies `/Applications/Godot.app` into `GodotProject/.debug/Godot.app` and signs that copy with `godot-debug.entitlements` so Xcode can debug it. The normal `/Applications/Godot.app` remains untouched, and `GodotProject/.debug/` is ignored by Git.

The scaffold script writes the generated repo's absolute path into the shared Xcode scheme. Xcode's LLDB launcher does not reliably expand `$(PROJECT_DIR)` in the executable path field, so regenerate the project or edit the scheme if you move the generated folder.
The external target deliberately keeps the Makefile as the source of truth for the Swift toolchain instead of inheriting Xcode's build environment.

### 2. Open the Godot project

Open `GodotProject/` in Godot 4. Godot will automatically load `MyExtension.gdextension` and register the `SpinningCube` node type.

### 3. Use your Swift node

In any 3D scene, add a child node and search for **SpinningCube** — it will appear under **Node3D**. It will create a spinning box at runtime.

## Adding your own Swift nodes

1. Create a new Swift file under `SwiftExtension/Sources/MyExtension/`.
2. Annotate your class with `@Godot` and subclass a Godot base type.
3. Add the new type to the `#initSwiftExtension` call in `MyExtension.swift`.
4. Run `make`, optionally run `make verify`, and restart/reload the Godot editor.

## Rebuilding without restarting Godot

Use **Project > Reload Current Project** in the Godot editor after running `make` to pick up the updated library.

## Debugging in Xcode

Xcode can attach its debugger to a running Godot process so you can set Swift breakpoints in your extension.
The Makefile also includes terminal LLDB helpers if you prefer a command-line debugger.

### One-time setup: re-sign Godot

The official Godot binary is signed without the `com.apple.security.get-task-allow` entitlement, which macOS requires before an external debugger can attach. The Xcode workflow's `make prepare-godot-debug` target signs a copied Godot app under `GodotProject/.debug/`, so you usually do not need to modify `/Applications/Godot.app`.

If you prefer to attach Xcode to your normal installed Godot app, re-sign it once with an ad-hoc signature that includes that entitlement:

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

### Fix incomplete indexing in Xcode

Xcode's indexer needs to build the local Swift package scheme before it can fully resolve SwiftGodot's generated API:

1. Open `MyExtension.xcodeproj`.
2. Select the `MyExtension` Swift package scheme.
3. Build with **Cmd-B**.
4. Open the **Issue Navigator** (**Cmd-5**). At the bottom you may see a prompt to **Trust & Enable** the SwiftGodot macro/plugin. Click it; Xcode may ask you to do this twice.
5. Switch back to the `MyExtension-Godot` scheme for Godot debugging.

Once the package scheme has built, symbol search, completion, option-click docs, and "Cannot find X in scope" errors should settle down.

### Running tests in Xcode

Use **Cmd-U** on the `MyExtension-Godot` scheme to run the native `MyExtensionTests` XCTest target. That target links the local Swift package product and uses the same test sources as `make test`, but the Godot Makefile target is intentionally disabled for the Test action so Xcode does not build or launch Godot just to run unit tests.

From the terminal, you can run the same Swift package tests with:

```bash
make test
```

### Attaching to a running game

1. Run `make` to build the debug `.dylib`.
2. Open `GodotProject/` in Godot and press **Run** (F5).
3. In Xcode, open `MyExtension.xcodeproj`.
4. Set any breakpoints you want in your Swift source files.
5. In the menu bar choose **Debug › Attach to Process by PID or Name…**, type `Godot`, and click **Attach**.

Xcode will attach to the Godot process and stop at your Swift breakpoints.

### Debugging with LLDB from Make

For command-line debugging, you can launch Godot under LLDB:

```bash
make debug-run
```

At the LLDB prompt, type:

```text
run
```

Or attach LLDB to an already-running Godot process:

```bash
make debug-attach
```

Use either `make debug-run` or `make debug-attach`, not both. `debug-run` launches Godot under LLDB from the start; `debug-attach` attaches to a Godot process you already started.

`make debug-attach` builds first, verifies the copied dylibs, and then runs `lldb -n Godot`. If your Godot process uses a different name, pass it with `GODOT_PROCESS`:

```bash
make debug-attach GODOT_PROCESS=Godot
```

These targets use terminal LLDB, not Xcode's GUI debugger. Breakpoints set in Xcode do not automatically carry over to terminal LLDB. To use Xcode breakpoints in Xcode, use **Debug > Attach to Process by PID or Name...** as described above.

## Project notes

See [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) for the current debugging notes, known setup decisions, and fixes discovered while getting this project running.
See [TEMPLATE_USAGE.md](TEMPLATE_USAGE.md) for instructions on using this repo as a starter for a new SwiftGodot project.
