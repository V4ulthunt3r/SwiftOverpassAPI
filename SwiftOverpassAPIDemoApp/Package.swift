// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SwiftOverpassAPIDemoApp",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(path: "../SwiftOverpassAPI")
    ],
    targets: [
        .target(
            name: "SwiftOverpassAPIDemoApp",
            dependencies: ["SwiftOverpassAPI"]
        )
    ]
) 