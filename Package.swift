// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PDFPreviewer",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "PDFPreviewer",
            targets: ["PDFPreviewer"]
        ),
    ],
    targets: [
        .target(
            name: "PDFPreviewer",
            swiftSettings: [
//                .unsafeFlags(["-strict-concurrency=complete"]
//                            )
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
