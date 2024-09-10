import ConsoleKit

/// ConsoleKit.Consoleに準拠するテスト用のフェイク
public final class TestConsole: Console, @unchecked Sendable {
    /// 入力キュー
    ///
    /// inputなどのメソッドで標準入力を求められ場合、この配列の先頭から順に値が払い出されます。
    /// 標準入力を要求された際に、この配列が空である場合、fatalErrorが投げられます。
    public var inputQueue: [String]

    /// ターミナルのサイズ
    ///
    /// 値は初期化時に設定可能です。
    public let size: (width: Int, height: Int)

    /// ユーザー情報
    ///
    /// 値は初期化時に設定可能です。
    public var userInfo: [ConsoleKitTerminal.AnySendableHashable: any Sendable]

    /// コンソールの動作記録
    ///
    /// このフェイクに対して入出力を行った記録がこの配列に追加されていきます。
    public var records: [Record] = []

    /// イニシャライザ
    /// - Parameters:
    ///   - inputQueue: 標準入力のキュー
    ///   - size: ターミナルのサイズ
    ///   - userInfo: ユーザー情報
    public init(
        inputQueue: [String] = [],
        size: (width: Int, height: Int) = (width: 400, height: 300),
        userInfo: [ConsoleKitTerminal.AnySendableHashable: any Sendable] = [:]
    ) {
        self.inputQueue = inputQueue
        self.size = size
        self.userInfo = userInfo
    }

    public func input(isSecure: Bool) -> String {
        guard let first = inputQueue.first else {
            fatalError("TestConsole.input(isSecure:) was called, but no input was provided.")
        }
        inputQueue = Array(inputQueue.dropFirst())
        records.append(.input(secure: isSecure, returning: first))
        return first
    }

    public func clear(_ type: ConsoleKitTerminal.ConsoleClear) {
        records.append(.clear(type: type))
    }

    public func output(_ text: ConsoleKitTerminal.ConsoleText, newLine: Bool) {
        let string = text.fragments.map(\.string).joined()
        let style = text.fragments.first?.style ?? .plain
        records.append(.output(text: string, newLine: newLine, style: style))
    }

    public func report(error: String, newLine: Bool) {
        records.append(.report(error: error, newLine: newLine))
    }

    /// フェイクに対する操作記録
    public enum Record: Hashable {
        /// 標準入力記録
        /// - secure: セキュア入力かどうか
        /// - returning: 標準入力で返された値
        case input(secure: Bool, returning: String)
        /// ターミナルクリア記録
        /// - type: クリアタイプ
        case clear(type: ConsoleKitTerminal.ConsoleClear)
        /// 標準出力記録
        /// - text: 出力テキスト
        /// - newLine: 改行するかどうか
        case output(text: String, newLine: Bool, style: ConsoleStyle)
        /// エラーレポート記録
        /// - error: エラーテキスト
        /// - newLine: 改行するかどうか
        case report(error: String, newLine: Bool)
    }
}

extension ConsoleColor: @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.black, .black): true
        case (.red, .red): true
        case (.green, .green): true
        case (.yellow, .yellow): true
        case (.blue, .blue): true
        case (.magenta, .magenta): true
        case (.cyan, .cyan): true
        case (.white, .white): true
        case (.brightBlack, .brightBlack): true
        case (.brightRed, .brightRed): true
        case (.brightGreen, .brightGreen): true
        case (.brightYellow, brightYellow): true
        case (.brightBlue, .brightBlue): true
        case (.brightMagenta, .brightMagenta): true
        case (.brightCyan, .brightCyan): true
        case (.brightWhite, .brightWhite): true
        case (.palette(let lhs), .palette(let rhs)): lhs == rhs
        case (.custom(let lr, let lg, let lb), .custom(let rr, let rg, let rb)): lr == rr && lg == rg && lb == rb
        default: false
        }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

extension ConsoleStyle: @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isBold == rhs.isBold &&
        lhs.background == rhs.background &&
        lhs.color == rhs.color
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isBold)
        hasher.combine(background)
        hasher.combine(color)
    }
}

extension ConsoleTextFragment: @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.string == rhs.string &&
        lhs.style == rhs.style
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
        hasher.combine(style)
    }
}

extension ConsoleText: @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.fragments == rhs.fragments
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fragments)
    }
}
