# Project Context

This repo is a barebones Godot 4 project with a Swift GDExtension built through SwiftGodot.

## Verified Local Setup

- Godot: 4.6.1 stable worked when opening `GodotProject/`.
- Swift: 6.3.1 was used to run `make`.
- The Swift package declares `// swift-tools-version: 5.9`.

## Important Fixes

- `SwiftExtension/Package.swift` intentionally lists only `.macOS(.v14)` in `platforms`.
- Do not re-add `.iOS(.v18)` unless the package tools version is raised to a PackageDescription version that supports it. With Swift tools 5.9, `.iOS(.v18)` makes `swift build` fail while evaluating the manifest.
- `GodotProject/project.godot` records Godot 4.6 metadata after the project was opened successfully in Godot 4.6.1.

## Build Notes

Run from the repo root:

```bash
make
```

The build compiles the Swift package and copies these runtime artifacts into `GodotProject/bin/`:

```text
libMyExtension.dylib
libSwiftGodot.dylib
```

Godot loads `MyExtension.gdextension`, which points at `res://bin/libMyExtension.dylib` and uses the exported `swift_entry_point` symbol.

## Troubleshooting Notes

- If `make` fails before compiling sources with an error about `.iOS(.v18)` being unavailable, check that `SwiftExtension/Package.swift` still targets only macOS or raise the Swift tools version intentionally.
- If Godot says it cannot get class `SpinningCube`, run `make` first and then reopen or reload the Godot project so the GDExtension is imported.
- A first SwiftGodot build can take a while because it builds SwiftSyntax, SwiftGodot's generator plugins, and the generated Godot bindings.
