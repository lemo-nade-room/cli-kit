import ConsoleKit
import Foundation

public struct Application: Sendable {

  public var commands: Commands

  public var asyncCommands: AsyncCommands

  public init(commands: Commands = .init(), asyncCommands: AsyncCommands = .init()) {
    self.commands = commands
    self.asyncCommands = asyncCommands
  }

  public func execute(arguments: [String] = ProcessInfo.processInfo.arguments) async throws {
    let combinedCommands = AsyncCommands(
      commands: self.asyncCommands.commands.merging(self.commands.commands) { $1 },
      defaultCommand: self.asyncCommands.defaultCommand ?? self.commands.defaultCommand,
      enableAutocomplete: self.asyncCommands.enableAutocomplete || self.commands.enableAutocomplete
    ).group()

    let commandInput = CommandInput(arguments: arguments)
    let console: some Console = Terminal()
    let context = CommandContext(console: console, input: commandInput)
    try await console.run(combinedCommands, with: context)
  }
}
