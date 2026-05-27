// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ProductCatalog",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ProductCatalog", targets: ["ProductCatalog"])
    ],
    targets: [
        .target(
            name: "ProductCatalog",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "ProductCatalogTests",
            dependencies: ["ProductCatalog"]
        )
    ],
    swiftLanguageModes: [.v6]
)
