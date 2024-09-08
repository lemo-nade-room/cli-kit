import ConsoleKit
import Foundation

/// `ConsoleKit`で作成した`AsyncCommand`を実行するサービス
///
/// 作成した`AsyncCommand`を`use`メソッドで登録後、`run`メソッドで実行を行う
/// ```swift
/// var cli = CLIKitService(help: "サンプルCLI")
/// cli.use(AddCommand(), as: "add")
/// cli.use(CommitCommand(), as: "commit")
/// await cli.run()
/// ```
public struct CLIKitService: Sendable {
    public var help: String
    public var console: any Console
    public var input: CommandInput
    public var asyncCommands: AsyncCommands

    /// イニシャライザ
    ///
    /// - Parameters:
    ///  - help: CLI自体のヘルプ表記
    ///  - console: 標準入出力。デフォルトでTerminal
    ///  - input: コマンドライン引数からの入力
    ///  - asyncCommands: 登録されたAsyncCommandを管理する構造体
    public init(
        help: String = "",
        console: any Console = Terminal(),
        input: CommandInput = .init(arguments: ProcessInfo.processInfo.arguments),
        asyncCommands: AsyncCommands = AsyncCommands(enableAutocomplete: true)
    ) {
        self.help = help
        self.console = console
        self.input = input
        self.asyncCommands = asyncCommands
    }

    /// CLIを実行する
    public func run() async {
        do {
            try await console.run(asyncCommandGroup, with: commandContext)
        } catch let error {
            console.error("\(error)")
        }
    }

    /// AsyncCommandを登録する
    public mutating func use(_ asyncCommand: any AsyncCommand, as name: String) {
        asyncCommands.use(asyncCommand, as: name)
    }

    /// AsyncCommandを登録する
    public mutating func use(_ asyncCommand: any AsyncCommand, as name: String, isDefault: Bool) {
        asyncCommands.use(asyncCommand, as: name, isDefault: isDefault)
    }

    private var commandContext: CommandContext {
        .init(console: console, input: input)
    }

    private var asyncCommandGroup: AsyncCommandGroup {
        asyncCommands.group(help: help)
    }
}
