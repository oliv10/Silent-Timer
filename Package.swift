// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SilentStatusTimer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SilentStatusTimer", targets: ["SilentStatusTimer"])
    ],
    targets: [
        .executableTarget(
            name: "SilentStatusTimer",
            path: "Sources"
        )
    ]
)
