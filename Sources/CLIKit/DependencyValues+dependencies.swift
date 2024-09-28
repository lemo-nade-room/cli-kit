import AsyncHTTPClient
import Dependencies
import Fluent
import NIOPosix

extension DependencyValues {
    /// Fluent Database
    ///
    /// データベースが設定されている場合のみ使用可能
    public var db: any Fluent.Database {
        databases.database(logger: logger, on: eventLoopGroup.any())!
    }

    /// CLIKitのlogger
    public var logger: Logger {
        get { self[LoggerKey.self] }
        set { self[LoggerKey.self] = newValue }
    }
    private enum LoggerKey: DependencyKey {
        static var liveValue: Logger {
            fatalError("Value of type \(Value.self) is not registered in this context")
        }
    }

    public var databases: Databases {
        get { self[DatabasesKey.self] }
        set { self[DatabasesKey.self] = newValue }
    }
    private enum DatabasesKey: DependencyKey {
        static var liveValue: Databases {
            fatalError("Value of type \(Value.self) is not registered in this context")
        }
    }

    public var eventLoopGroup: MultiThreadedEventLoopGroup {
        get { self[EventLoopGroupKey.self] }
        set { self[EventLoopGroupKey.self] = newValue }
    }
    private enum EventLoopGroupKey: DependencyKey {
        static var liveValue: MultiThreadedEventLoopGroup {
            fatalError("Value of type \(Value.self) is not registered in this context")
        }
    }

    public var threadPool: NIOThreadPool {
        get { self[ThreadPoolKey.self] }
        set { self[ThreadPoolKey.self] = newValue }
    }
    private enum ThreadPoolKey: DependencyKey {
        static var liveValue: NIOThreadPool {
            fatalError("Value of type \(Value.self) is not registered in this context")
        }
    }

    public var httpClient: HTTPClient {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
    private enum HTTPClientKey: DependencyKey {
        static var liveValue: HTTPClient {
            fatalError("Value of type \(Value.self) is not registered in this context")
        }
    }
}
