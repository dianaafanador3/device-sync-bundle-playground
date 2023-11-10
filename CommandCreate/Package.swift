// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Command",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", from: "10.44.0"),
    ],
    targets: [
        .executableTarget(
            name: "Command",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-swift")
            ]
        )
    ]
)
