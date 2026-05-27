// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ProductShowroomFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ProductShowroomFeature", targets: ["ProductShowroomFeature"])
    ],
    dependencies: [
        .package(path: "../../Core/DesignSystem"),
        .package(path: "../../Core/ProductCatalog")
    ],
    targets: [
        .target(
            name: "ProductShowroomFeature",
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
            name: "ProductShowroomFeatureTests",
            dependencies: [
                "ProductShowroomFeature",
                "ProductCatalog"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
