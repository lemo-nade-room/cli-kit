import ConsoleKit
import FluentKit
import Foundation
import NIOCore
import NIOPosix

public struct Application: Sendable {

  public var env: Environment

  public var console: any Console

  public var logger: Logger

  public var commands: Commands

  public var asyncCommands: AsyncCommands

  public var migrations: Migrations

  public var databases: Databases

  public var eventLoopGroup: EventLoopGroup

  public var threadPool: NIOThreadPool

  public init(
    env: Environment,
    console: any Console = Terminal(),
    logger: Logger = .init(label: "cli-kit"),
    commands: Commands = .init(),
    asyncCommands: AsyncCommands = .init(),
    migrations: Migrations = .init()
  ) {
    self.env = env

    self.console = console

    self.logger = logger

    self.commands = commands
    self.asyncCommands = asyncCommands

    self.migrations = migrations

    self.threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
    self.threadPool.start()

    self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

    databases = .init(threadPool: threadPool, on: eventLoopGroup)
  }

  public func execute(arguments: [String] = ProcessInfo.processInfo.arguments) async throws {
    let combinedCommands = AsyncCommands(
      commands: self.asyncCommands.commands.merging(self.commands.commands) { $1 },
      defaultCommand: self.asyncCommands.defaultCommand ?? self.commands.defaultCommand,
      enableAutocomplete: self.asyncCommands.enableAutocomplete || self.commands.enableAutocomplete
    ).group()

    let commandInput = CommandInput(arguments: arguments)
    var context = CommandContext(console: console, input: commandInput)
    context.application = self
    try await console.run(combinedCommands, with: context)
  }
}
