# Agent Notes

This repo is a Godot 4.6+ Swift GDExtension template powered by SwiftGodot. Read `PROJECT_CONTEXT.md` before making changes; it records the project-specific decisions, validation history, and known workflow details.

## Working Rules

- Run build and validation commands from the repo root, not from `GodotProject/`.
- Use `scripts/create_project.sh --name <Name> --dest <Path>` to scaffold renamed projects.
- Treat `GodotProject/` as Godot-owned. Keep Godot scenes and project files on disk, but do not add them to the Xcode navigator unless there is a clear reason.
- Keep the Xcode project focused on Swift package indexing, the Godot run/debug scheme, native XCTest support, scripts, and docs.
- Do not commit generated `.build`, `.swiftpm/xcode`, `.godot` editor/cache files, copied dylibs, `GodotProject/.debug/`, Xcode user state, `Makefile.local`, `.DS_Store`, or `*.profraw`.
- Preserve `GodotProject/.godot/extension_list.cfg`; Godot needs it to load the GDExtension from a clean checkout or generated project.

## Validation

For template/scaffold changes, generate a temporary project and validate the generated output:

```bash
scripts/create_project.sh --name TestProject --dest /private/tmp/TestProject
cd /private/tmp/TestProject
xcodebuild -list -project TestProject.xcodeproj
make test
make
make verify
```

When Xcode test wiring changes, also validate:

```bash
xcodebuild test -project TestProject.xcodeproj -scheme TestProject-Godot -destination 'platform=macOS'
```

The shared Xcode scheme uses stable `/private/tmp` launcher paths. Test Xcode launch behavior on a generated project so the project-name replacements have updated those paths.

## Commit Style

When preparing commits for this repo:

- Ask before creating a commit unless the user has explicitly approved it.
- Write the subject in past tense, for example `Added native Xcode test target`.
- If changes were more complex than the subject covers, use a short explanatory body with bulleted sections after the subject.
