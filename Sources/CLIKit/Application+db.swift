import FluentKit

extension Application {

  public var db: Database {
    self.db(nil)
  }

  public func db(_ id: DatabaseID?) -> Database {
    self.databases
      .database(
        id,
        logger: self.logger,
        on: self.eventLoopGroup.next()
      )!
  }
}
