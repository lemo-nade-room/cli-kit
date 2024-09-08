import ConsoleKit

extension CommandContext {
    /// 任意の型の値を保存できるストレージ
    public actor Storage {
        private var storage: [ObjectIdentifier: any Sendable] = [:]

        public init() {}

        /// Storageに値を格納する
        /// - Parameters:
        ///   - key: キーとなる型
        ///   - value: 格納する値
        public func set<K: Sendable>(key: K.Type, _ value: K) {
            storage[ObjectIdentifier(K.self)] = value
        }

        /// 型に対応する値を取得する
        /// - Parameter key: キーとなる型
        /// - Returns: 対応する値。存在しない場合、nilを返す
        public func get<K: Sendable>(_ key: K.Type) -> K? {
            guard let value = storage[ObjectIdentifier(K.self)] else { return nil }
            return value as? K
        }

        /// 型に対応する値を取得する。ない場合には初期化しその値を返す
        /// - Parameter initialize: 値を初期化するためのクロージャ
        /// - Returns: 格納済みの値または新たに初期化し作成した値
        public func get<K: Sendable>(initialize: @Sendable () async throws -> K) async rethrows -> K {
            try await get(K.self, initialize: initialize)
        }

        /// 型に対応する値
        /// - Parameters:
        ///   - key: キーとなる型
        ///   - initialize: 値を初期化するためのクロージャ
        /// - Returns: 格納済みの値または新たに初期化し作成した値
        public func get<K: Sendable>(_ key: K.Type, initialize: @Sendable () async throws -> K) async rethrows -> K {
            if let old = get(key) { return old }
            let new = try await initialize()
            set(key: K.self, new)
            return new
        }
    }

    private static let storage = Storage()
    public var storage: Storage { Self.storage }
}
