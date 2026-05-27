// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CartFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CartFeature", targets: ["CartFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/ProductCatalog")
    ],
    targets: [
        .target(
            name: "CartFeature",
            dependencies: [
                "DesignSystem",
                "ProductCatalog"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "CartFeatureTests",
            dependencies: [
                "CartFeature",
                "ProductCatalog"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
