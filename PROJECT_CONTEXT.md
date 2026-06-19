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
- SwiftGodot is pinned to revision `ead7bffc9546c1740678a36096282e1a811b7da6` so upstream manifest changes do not unexpectedly break Xcode package resolution or indexing.

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
`GodotProject/.godot/extension_list.cfg` is intentionally tracked because Godot uses it to load the GDExtension from a clean checkout. Other `.godot` editor/cache files remain ignored.

Run `make toolchain` to confirm which Swift CLI the Makefile uses. `SWIFT_BIN` prefers the `swift-latest` user toolchain symlink or Swiftly before falling back to `swift`, which keeps Xcode external builds from accidentally using Xcode's default toolchain.

## Xcode Notes

- Open `MyExtension.xcodeproj` for the Godot run/debug workflow.
- The Xcode project references `SwiftExtension/` as a local Swift package. This is for SourceKit indexing, completion, symbol search, option-click docs, and a real SwiftPM graph inside Xcode.
- The Xcode project intentionally does not list `GodotProject/` assets in the navigator. Godot scenes and project files stay on disk and should be edited in Godot, while Xcode stays focused on Swift, tests, scripts, and docs.
- Use the shared `MyExtension-Godot` scheme.
- `Cmd-B` runs the external build target, which calls `make debug verify`.
- `Cmd-R` builds the external target, runs `make prepare-xcode-run`, prepares a debug-signed Godot copy under `/private/tmp/MyExtension-Godot.app`, and launches the symlinked `/private/tmp/MyExtension-GodotProject` path through Xcode's LLDB launcher.
- `Cmd-U` on the `MyExtension-Godot` scheme runs the native `MyExtensionTests` XCTest target in the root Xcode project. That target links the local Swift package product and uses the existing `SwiftExtension/Tests/MyExtensionTests` sources.
- The Godot legacy target is intentionally not built for the Test action, so `Cmd-U` does not run the Makefile build before tests.
- The local Swift package scheme, `MyExtension`, should be built once after a fresh checkout, package reset, or DerivedData clear so SwiftGodot's generated API exists for Xcode indexing. Then switch back to `MyExtension-Godot` for Godot debugging.
- The external target intentionally sets `passBuildSettingsInEnvironment = 0`; letting Xcode inject its build environment into SwiftPM can break SwiftGodot generated builds.
- The Makefile remains the source of truth for the Swift CLI through `SWIFT_BIN`. `Makefile.local` is ignored and can hold machine-specific overrides.
- The shared scheme uses stable `/private/tmp` launcher and project paths because Xcode's LLDB launcher does not reliably expand project-relative paths in the executable field.
- The debug Godot copies are ignored by Git or written under `/private/tmp` and signed with `godot-debug.entitlements` because the notarized `/Applications/Godot.app` build denies debugger attach.

## Template Notes

- Use `scripts/create_project.sh` to generate a renamed project from this template.
- Keep the README's first-screen path focused on generating a new project; in-place template build instructions should remain secondary.
- The script accepts `--name`, `--template`, and `--dest`, and updates the Swift package, source folder, GDExtension file, dylib references, and Godot project name.
- The script recreates minimal `.godot` extension-load files for the generated project while leaving noisy editor/cache metadata ignored.
- The script also renames the Xcode project and shared scheme for the generated project. The shared scheme uses project-name-specific `/private/tmp` launcher paths rather than stamping the generated repo path into the scheme.
- The script rewrites the project workspace self-reference so generated `.xcodeproj/project.xcworkspace/contents.xcworkspacedata` points at the generated `.xcodeproj`.

## Commit Notes

- Confirm with the user before creating commits.
- Use a short past-tense commit subject.
- Put explanatory details after the subject as bullet points.
- When the user says to push, push the current branch to its current tracking branch.

## Troubleshooting Notes

- If `make` fails before compiling sources with an error about `.iOS(.v18)` being unavailable, check that `SwiftExtension/Package.swift` still targets only macOS or raise the Swift tools version intentionally.
- If Godot says it cannot get class `SpinningCube`, run `make verify` and confirm `GodotProject/.godot/extension_list.cfg` points at the project `.gdextension`, then reopen or reload the Godot project.
- A first SwiftGodot build can take a while because it builds SwiftSyntax, SwiftGodot's generator plugins, and the generated Godot bindings.
