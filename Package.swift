// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArsenalFixtures",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ArsenalFixtures",
            path: "Sources/ArsenalFixtures"
        )
    ]
)
