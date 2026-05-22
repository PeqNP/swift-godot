# Template Usage

Use this repo as a starting point for a new Godot 4 project with a Swift GDExtension powered by SwiftGodot.

## Platform Scope

This template is verified for macOS development with Godot 4.6.

SwiftGodot currently describes support for macOS, iOS, Linux, and Windows, but this repo only includes the macOS build path out of the box:

- macOS: verified. `make` builds `.dylib` files and copies them into `GodotProject/bin/`.
- iOS: expected to be possible with SwiftGodot, but this template does not include an iOS build/export pipeline.
- Linux: expected to be possible with SwiftGodot, but you must build Linux `.so` libraries and package them for Godot.
- Windows: expected to be possible with SwiftGodot, but you must build Windows `.dll` files and include the required Swift runtime DLLs.

Do not assume this template can target every platform Godot can export to. Each target platform needs native Swift build support, matching GDExtension library entries, and runtime packaging.

## Create a New Project Copy

From a parent folder where you want the new project to live:

```bash
cp -R /path/to/swift-godot MyNewProject
cd MyNewProject
```

If you copied the `.git` directory and want a fresh repo history:

```bash
rm -rf .git
git init
```

## Rename the Project

The template uses `MyExtension` for the Swift extension and `MyFirstGame` for the Godot project name. Rename these deliberately so SwiftPM, the generated dylib, and Godot's `.gdextension` file stay in agreement.

### Swift Package

Edit `SwiftExtension/Package.swift`:

- Change `name: "MyExtension"` to your Swift package name.
- Change `.library(name: "MyExtension", type: .dynamic, targets: ["MyExtension"])`.
- Change the target name from `"MyExtension"` if you want the Swift module to use a new name.

If you rename the target, also rename this folder:

```text
SwiftExtension/Sources/MyExtension/
```

### Swift Source

Edit the Swift files under `SwiftExtension/Sources/<TargetName>/`.

The exported entry point is currently:

```swift
#initSwiftExtension(cdecl: "swift_entry_point", types: [SpinningCube.self])
```

You can keep `swift_entry_point` as-is. If you change it, update `GodotProject/MyExtension.gdextension` to use the same `entry_symbol`.

Register every custom SwiftGodot type in the `types:` array.

### Build File

Edit `Makefile`:

- Update `LIB_NAME` if you use it later for scripts or cleanup.
- Update copy paths if you change the Swift package directory, Godot project directory, or output library name.

The dynamic library name comes from the SwiftPM product name. For a product named `MyGameExtension`, SwiftPM builds:

```text
libMyGameExtension.dylib
```

### Godot GDExtension File

Rename `GodotProject/MyExtension.gdextension` if desired, then edit it:

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = 4.2

[libraries]
macos.debug = "res://bin/libMyExtension.dylib"
macos.release = "res://bin/libMyExtension.dylib"
```

Update the macOS library paths to match the SwiftPM product name you chose.

For example, if your SwiftPM product is `MyGameExtension`:

```ini
macos.debug = "res://bin/libMyGameExtension.dylib"
macos.release = "res://bin/libMyGameExtension.dylib"
```

### Godot Project Name

Edit `GodotProject/project.godot`:

```ini
config/name="MyFirstGame"
```

Change it to the name you want Godot to show in the project manager and window title.

## Keep These Settings Unless You Know Why

- Keep `SwiftExtension/Package.swift` on `.macOS(.v14)` unless you are intentionally adding platform support.
- Do not add `.iOS(.v18)` while the package declares `// swift-tools-version: 5.9`; that combination prevents SwiftPM from evaluating the manifest.
- Keep `swift_entry_point` unless you update both Swift source and the `.gdextension` file together.
- Keep `libSwiftGodot.dylib` in `GodotProject/bin/`; `libMyExtension.dylib` depends on it at runtime.

## First Run Checklist

From the repo root:

```bash
make
```

Confirm the Godot bin folder contains:

```text
GodotProject/bin/lib<YourExtensionName>.dylib
GodotProject/bin/libSwiftGodot.dylib
```

Open `GodotProject/` in Godot.

Confirm:

- The project opens without GDExtension load errors.
- Your custom Swift node type appears in the Add Child Node dialog.
- The main scene runs.

## Prompt for Future AI Assistant Chats

You can ask an AI coding assistant to create a new project from this template with a prompt like:

```text
Use /Users/jacobhawken/code/gamedev/SwiftGodot/swift-godot as the template for a new SwiftGodot project in <new absolute folder>. Rename the Swift package, target, product, source folder, dylib references, Godot project name, and .gdextension file for a project named <ProjectName>. Then run make and verify the Godot extension loads.
```

Replace `<new absolute folder>` and `<ProjectName>` with the real destination and name.

## Troubleshooting

See `PROJECT_CONTEXT.md` for the setup decisions and issues already discovered while getting this template running.
