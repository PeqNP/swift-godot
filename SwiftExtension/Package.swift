// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyExtension",
    products: [
        .library(name: "MyExtension", type: .dynamic, targets: ["MyExtension"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
    ],
    targets: [
        .target(
            name: "MyExtension",
            dependencies: ["SwiftGodot"]
        )
    ]
)
