import ConsoleKit
import Fluent
import FluentSQLiteDriver
import Foundation
import Logging
import NIOCore
import NIOPosix

extension CommandContext {

    /// Fluent Database
    ///
    /// データベースが設定されている場合のみ使用可能
    public var db: any Database {
        get async {
            guard
                let databases = await storage.get(Databases.self),
                let db = await databases.database(logger: logger, on: eventLoopGroup.any())
            else {
                fatalError("データベースが初期化されていません。CLIKitService(sqlitePath: \"...\")で初期化してください")
            }
            return db
        }
    }

    /// CLIKitのlogger
    public var logger: Logger {
        get async {
            await storage.get { Logger(label: "CLIKit") }
        }
    }

    /// Fluent Databases
    ///
    /// データベースが設定されている場合のみ存在する
    public var databases: Databases? {
        get async {
            await storage.get(Databases.self)
        }
    }

    public var eventLoopGroup: MultiThreadedEventLoopGroup {
        get async {
            await storage.get { .singleton }
        }
    }

    func initDatabase(sqliteURL: URL, migrations: Migrations, migrationLogLevel: Logger.Level) async throws {
        let logger = await logger
        let eventLoopGroup = await eventLoopGroup
        let threadPool: NIOThreadPool = .init(numberOfThreads: System.coreCount)
        try await threadPool.shutdownGracefully()
        threadPool.start()
        let databases = Databases(threadPool: threadPool, on: eventLoopGroup)
        databases.use(.sqlite(.file(sqliteURL.absoluteString)), as: .sqlite)
        await storage.set(key: Logger.self, logger)
        await storage.set(key: MultiThreadedEventLoopGroup.self, eventLoopGroup)
        await storage.set(key: NIOThreadPool.self, threadPool)
        await storage.set(key: Databases.self, databases)

        try await autoMigrate(
            databases: databases,
            migrations: migrations,
            on: eventLoopGroup.any(),
            migrationLogLevel: migrationLogLevel
        )
    }

    func autoMigrate(
        databases: Databases,
        migrations: Migrations,
        on eventLoop: EventLoop,
        migrationLogLevel: Logger.Level
    ) async throws {
        let migrator = await Migrator(
            databases: databases,
            migrations: migrations,
            logger: logger,
            on: eventLoop,
            migrationLogLevel: migrationLogLevel
        )
        try await withCheckedThrowingContinuation { continuation in
            let future = migrator
                .setupIfNeeded()
                .flatMap { migrator.prepareBatch() }
            future.whenSuccess { continuation.resume(returning: ()) }
            future.whenFailure { continuation.resume(throwing: $0) }
        }
    }

    func shutdown() async {
        if let databases = await databases {
            await databases.shutdownAsync()
        }
    }
}
