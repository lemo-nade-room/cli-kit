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
    // Vapor
    .package(url: "https://github.com/vapor/vapor.git", from: "4.91.1"),
    // Fluent Kit
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    // 🪶 Fluent driver for SQLite.
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CLIKit",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent"),
      ]
    ),
    .testTarget(
      name: "CLIKitTests",
      dependencies: [
        "CLIKit",
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      ]),
  ]
)
