// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import PackageDescription

let package = Package(
    name: "content-management-swift",
    platforms: [.iOS("14.0"), .macOS(.v12)],
    products: [
        .library(
            name: "OracleContentCore",
            targets: [
                "OracleContentCore"
            ]),
        .library(
            name: "OracleContentDelivery",
            targets: [
                "OracleContentDelivery"
            ]),
        .library(
            name: "OracleContentTest",
            targets: ["OracleContentTest"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "OracleContentCore",
            path: "Sources/OracleContentCore",
            exclude: [
                "OracleContentCore.h",
                "Info.plist",
                "OracleContentCoreDocumentation.docc"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "OracleContentDelivery",
            dependencies: ["OracleContentCore"],
            path: "Sources/OracleContentDelivery",
            exclude: ["Info.plist", "OracleContentDeliveryDocumentation.docc"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "OracleContentTest",
            dependencies: ["OracleContentCore"],
            path: "Sources/OracleContentTest",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "OracleContentCoreTests",
            dependencies: ["OracleContentCore", "OracleContentTest"],
            path: "Tests/OracleContentCoreTests",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OracleContentDeliveryTests",
            dependencies: ["OracleContentCore", "OracleContentDelivery", "OracleContentTest"],
            path: "Tests/OracleContentDeliveryTests",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources"),
                .process("Assets/Resources"),
                .process("Taxonomies/Resources")
            ]),
        .testTarget(
            name: "OracleContentTestTests",
            dependencies: ["OracleContentCore", "OracleContentTest"],
            path: "Tests/OracleContentTestTests",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .process("action.png")
            ]
        )
    ]
)
