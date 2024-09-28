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
        .library(
            name: "CLITestKit",
            targets: ["CLITestKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/console-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand.git", from: "1.4.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CLIKit",
            dependencies: [
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            swiftSettings: swiftSettings,
            plugins: swiftLintPlugins
        ),
        .testTarget(
            name: "CLIKitTests",
            dependencies: [
                "CLIKit",
                .product(name: "Testing", package: "swift-testing"),
                .target(name: "CLITestKit"),
            ],
            swiftSettings: swiftSettings,
            plugins: swiftLintPlugins
        ),
        .target(
            name: "CLITestKit",
            dependencies: [
                .target(name: "CLIKit"),
            ],
            swiftSettings: swiftSettings,
            plugins: swiftLintPlugins
        ),
        .testTarget(
            name: "CLITestKitTests",
            dependencies: [
                "CLITestKit",
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
