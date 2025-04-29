// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftOverpassAPI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftOverpassAPI",
            targets: ["SwiftOverpassAPI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftOverpassAPI",
            dependencies: [],
            path: "Source")
    ]
) 
