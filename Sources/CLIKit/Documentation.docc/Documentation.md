# ``cli-kit``

SwiftのCLIに必要なライブラリの初期化を容易にするライブラリ

## Overview

以下のライブラリの初期化を行い容易に使用をすることができます。

- Fluent（SQLite）
- ConsoleKit
- SwiftCommand
- AsyncHTTPClient
- SwiftDependencies

## Quick Start

### 依存関係に追加

CLIKitをプロジェクトに追加するには、Swift Package Managerを使用します。Package.swiftに以下の依存関係を追加してください。

```swift
dependencies: [
    .package(url: "https://github.com/lemo-nade-room/cli-kit.git", branch: "main")
]
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CLIKit", package: "cli-kit"),
    ]
),
```

### コマンドを作成・実行

```swift
import CLIKit
import ConsoleKit
import Dependencies
import Fluent
import Foundation

struct SampleCommand: AsyncCommand {
    var help = "sample"

    struct Signature: CommandSignature {
        @Option(name: "message", short: "m")
        var message: String?
    }

    @Dependency(\.db) var db
    @Dependency(\.httpClient) var httpClient

    func run(using context: CommandContext, signature: Signature) throws {
        context.console.output("Hello, \(signature.message ?? "World")!")
    }
}

struct SampleMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("samples")
            .id()
            .field("message", .string, .required)
            .create()
    }
    func revert(on database: any Database) async throws {
        try await database.schema("samples").delete()
    }
}

let sqliteURL = FileManager()
  .homeDirectoryForCurrentUser
  .appending(path: "file.sqlite")

var cli: CLI {
    var cli = CLI(help: "サンプルCLI")
    cli.use(SampleCommand(), as: "sample")
    cli.migrations.add(SampleMigration())
    return cli
}

try await cli.run()
```
