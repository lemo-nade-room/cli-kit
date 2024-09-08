import ConsoleKit
import Fluent
import Foundation
import Logging

/// `ConsoleKit`で作成した`AsyncCommand`を実行するサービス
///
/// 作成した`AsyncCommand`を`use`メソッドで登録後、`run`メソッドで実行を行う。
/// sqliteURLを指定することでSQLiteデータベースをFluent ORMで使用できる。
/// ```swift
/// let sqliteURL = FileManager()
///   .homeDirectoryForCurrentUser
///   .appending(path: "file.sqlite")
/// var cli = CLIKitService(help: "サンプルCLI", sqliteURL: sqliteURL)
/// cli.use(AddCommand(), as: "add")
/// cli.use(CommitCommand(), as: "commit")
/// cli.migrations.add(CommitMigration())
/// await cli.run()
/// ```
public struct CLIKitService: Sendable {
    public var help: String
    public var console: any Console
    public var input: CommandInput
    public var asyncCommands: AsyncCommands
    public var sqliteURL: URL?
    public let migrations: Migrations
    public var migrationLogLevel: Logger.Level

    /// イニシャライザ
    ///
    /// - Parameters:
    ///  - help: CLI自体のヘルプ表記
    ///  - console: 標準入出力。デフォルトでTerminal
    ///  - input: コマンドライン引数からの入力
    ///  - asyncCommands: 登録されたAsyncCommandを管理する構造体
    ///  - sqliteURL: SQLiteのファイルURL。指定された場合にデータベースが使用可能に設定される
    ///  - migrations: Fluentのマイグレーション
    ///  - migrationLogLevel: マイグレーションのログレベル
    public init(
        help: String = "",
        console: any Console = Terminal(),
        input: CommandInput = .init(arguments: ProcessInfo.processInfo.arguments),
        asyncCommands: AsyncCommands = AsyncCommands(enableAutocomplete: true),
        sqliteURL: URL? = nil,
        migrations: Migrations = .init(),
        migrationLogLevel: Logger.Level = .warning
    ) {
        self.help = help
        self.console = console
        self.input = input
        self.asyncCommands = asyncCommands
        self.sqliteURL = sqliteURL
        self.migrations = migrations
        self.migrationLogLevel = migrationLogLevel
    }

    /// CLIを実行する
    public func run() async {
        let context = CommandContext(console: console, input: input)
        do {
            if let sqliteURL {
                try await context.initDatabase(
                    sqliteURL: sqliteURL,
                    migrations: migrations,
                    migrationLogLevel: migrationLogLevel
                )
            }
            try await console.run(asyncCommandGroup, with: context)
        } catch let error {
            console.error("\(error)")
        }
        await context.shutdown()
    }

    /// AsyncCommandを登録する
    public mutating func use(_ asyncCommand: any AsyncCommand, as name: String) {
        asyncCommands.use(asyncCommand, as: name)
    }

    /// AsyncCommandを登録する
    public mutating func use(_ asyncCommand: any AsyncCommand, as name: String, isDefault: Bool) {
        asyncCommands.use(asyncCommand, as: name, isDefault: isDefault)
    }

    private var asyncCommandGroup: AsyncCommandGroup {
        asyncCommands.group(help: help)
    }
}
