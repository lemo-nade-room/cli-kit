import FluentKit

extension Application {
  public var migrator: Migrator {
    Migrator(
      databases: self.databases,
      migrations: self.migrations,
      logger: self.logger,
      on: self.eventLoopGroup.any(),
      migrationLogLevel: .info
    )
  }

  public func autoMigrate() async throws {
    try await self.migrator.setupIfNeeded().flatMap {
      self.migrator.prepareBatch()
    }.get()
  }

  public func autoRevert() async throws {
    try await self.migrator.setupIfNeeded().flatMap {
      self.migrator.revertAllBatches()
    }.get()
  }
}
