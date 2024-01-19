// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "cli-kit",
  platforms: [.macOS(.v14)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "CLIKit",
      targets: ["CLIKit"])
  ],
  dependencies: [
    // Console Kit
    .package(url: "https://github.com/vapor/console-kit.git", from: "4.14.1"),
    // Fluent Kit
    .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.45.1"),
    // Swift NIO
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CLIKit",
      dependencies: [
        .product(name: "ConsoleKit", package: "console-kit"),
        .product(name: "FluentKit", package: "fluent-kit"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
      ]
    ),
    .testTarget(
      name: "CLIKitTests",
      dependencies: ["CLIKit"]),
  ]
)
