import SwiftGodot

// Registers all @Godot types and exports the entry point "swift_entry_point"
// that is referenced in MyExtension.gdextension.
#initSwiftExtension(cdecl: "swift_entry_point", types: [SpinningCube.self])

/// A simple demo node: adds a spinning box mesh as a child.
/// Add it to any 3D scene via Node > Add Child Node > SpinningCube.
@Godot(.tool)
class SpinningCube: Node3D {
    public override func _ready() {
        let meshInstance = MeshInstance3D()
        meshInstance.mesh = BoxMesh()
        addChild(node: meshInstance)
    }

    public override func _process(delta: Double) {
        rotateY(angle: delta)
    }
}
