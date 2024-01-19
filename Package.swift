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
    .package(url: "https://github.com/vapor/console-kit.git", from: "4.14.1")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CLIKit",
      dependencies: [
        .product(name: "ConsoleKit", package: "console-kit")
      ]
    ),
    .testTarget(
      name: "CLIKitTests",
      dependencies: ["CLIKit"]),
  ]
)
