import Vapor

extension Vapor.Application {
  public func cliKit(configure: (Application) async throws -> Void) async throws {
    commands.defaultCommand = nil
    commands.commands = [:]
    asyncCommands.defaultCommand = nil
    asyncCommands.commands = [:]

    do {
      try await configure(self)
    } catch {
      logger.report(error: error)
      throw error
    }

    let combinedCommands = AsyncCommands(
      commands: self.asyncCommands.commands.merging(self.commands.commands) { $1 },
      defaultCommand: self.asyncCommands.defaultCommand ?? self.commands.defaultCommand,
      enableAutocomplete: self.asyncCommands.enableAutocomplete || self.commands.enableAutocomplete
    ).group()

    var context = CommandContext(console: self.console, input: self.environment.commandInput)
    context.application = self
    try await self.console.run(combinedCommands, with: context)
  }
}
