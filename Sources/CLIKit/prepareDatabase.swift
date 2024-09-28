import Fluent
import FluentSQLiteDriver
import Foundation
import NIOCore
import NIOPosix

func autoMigrate(
    databases: Databases,
    on eventLoop: some EventLoop,
    logger: Logger,
    migrations: Migrations,
    migrationLogLevel: Logger.Level
) async throws {
    let migrator = Migrator(
        databases: databases,
        migrations: migrations,
        logger: logger,
        on: eventLoop,
        migrationLogLevel: .warning
    )
    try await withCheckedThrowingContinuation { continuation in
        let future = migrator
            .setupIfNeeded()
            .flatMap { migrator.prepareBatch() }
        future.whenSuccess { continuation.resume(returning: ()) }
        future.whenFailure { continuation.resume(throwing: $0) }
    }
}
