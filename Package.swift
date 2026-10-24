// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Commerce",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CommerceApp", targets: ["CommerceApp"]),
        .library(name: "CommerceCore", targets: ["CommerceCore"]),
        .library(name: "CommercePresentation", targets: ["CommercePresentation"])
    ],
    targets: [
        .target(
            name: "CommerceApp",
            dependencies: [
                "CommercePresentation",
                "CommerceCore"
            ],
            path: "App"
        ),
        .target(name: "CommerceCore", path: "Sources/CommerceCore"),
        .target(name: "CommercePresentation", dependencies: ["CommerceCore"], path: "Sources/CommercePresentation"),
        .testTarget(name: "CommerceCoreTests", dependencies: ["CommerceCore"], path: "Tests/CommerceCoreTests")
    ]
)

