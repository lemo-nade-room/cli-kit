// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "cli-kit",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CLIKit",
            targets: ["CLIKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CLIKit",
            swiftSettings: swiftSettings,
            plugins: swiftLintPlugins
        ),
        .testTarget(
            name: "CLIKitTests",
            dependencies: [
                "CLIKit",
                .product(name: "Testing", package: "swift-testing"),
            ],
            swiftSettings: swiftSettings,
            plugins: swiftLintPlugins
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }

var swiftLintPlugins: [Target.PluginUsage] {
    guard Environment.enableSwiftLint else { return [] }
    return [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
    ]
}

enum Environment {
    static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
    static var enableSwiftLint: Bool {
        Self.get("SWIFTLINT") == "true"
    }
}
