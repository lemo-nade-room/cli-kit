# CLIKit

CLIKitは、Swiftで簡単にCLI（コマンドラインインターフェース）ツールを作成するためのライブラリです。`ConsoleKit`や`Fluent`などを活用して、非同期のコマンド実行やデータベース操作をシンプルに実装できます。

<p align="center">
    <a href="https://github.com/lemo-nade-room/cli-kit/actions/workflows/test.yaml">
        <img src="https://github.com/lemo-nade-room/cli-kit/actions/workflows/test.yaml/badge.svg" alt="Testing Status">
    </a>
    <a href="https://lemo-nade-room.github.io/cli-kit/documentation/clikit">
        <img src="https://design.vapor.codes/images/readthedocs.svg" alt="Documentation">
    </a>
    <a href="LICENSE">
        <img src="https://design.vapor.codes/images/mitlicense.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://design.vapor.codes/images/swift510up.svg" alt="Swift 5.10+">
    </a>
</p>

## 特徴

- 非同期のCLIコマンドを簡単に作成・管理
- `Fluent`を利用したデータベース操作のサポート
- `AsyncHTTPClient`を利用したHTTPリクエストサポート
- マイグレーションや自動マイグレーション機能のサポート

## サポート

- macOS >= 14
- 6.0 > Swift >= 5.10

## インストール

CLIKitをプロジェクトに追加するには、Swift Package Managerを使用します。`Package.swift`に以下の依存関係を追加してください。

```swift
dependencies: [
    .package(url: "https://github.com/lemo-nade-room/cli-kit.git", branch: "main")
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "CLIKit", package: "cli-kit"),
    ]
),
```

## 使用例

以下のコードは、CLIKitを使って簡単なCLIを作成する例です。

```swift
let sqliteURL = FileManager()
  .homeDirectoryForCurrentUser
  .appending(path: "file.sqlite")
var cli = CLI(help: "サンプルCLI")
cli.use(AddCommand(), as: "add")
cli.use(CommitCommand(), as: "commit")
cli.migrations.add(CommitMigration())
try await cli.run()
```

## ライセンス

このライブラリはMITライセンスで提供されています。詳細は[LICENSE](./LICENSE)ファイルをご覧ください。
