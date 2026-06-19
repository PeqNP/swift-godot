// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyExtension",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MyExtension", type: .dynamic, targets: ["MyExtension"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/migueldeicaza/SwiftGodot",
            revision: "ead7bffc9546c1740678a36096282e1a811b7da6"
        )
    ],
    targets: [
        .target(
            name: "MyExtension",
            dependencies: ["SwiftGodot"]
        ),
        .testTarget(
            name: "MyExtensionTests",
            dependencies: ["MyExtension"]
        )
    ]
)
