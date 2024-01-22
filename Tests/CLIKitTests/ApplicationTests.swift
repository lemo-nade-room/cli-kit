import ConsoleKit
import Vapor
import XCTest

@testable import CLIKit

final class ApplicationTests: XCTestCase {
  func test_command_can_be_called() async throws {
    // Arrange
    var env: Environment = .testing
    env.commandInput = CommandInput(arguments: ["<endpoint>", "call"])
    let app = Application(env)
    defer { app.shutdown() }

    final class CallCommand: Command, @unchecked Sendable {
      struct Signature: CommandSignature {}
      var called: Bool = false
      let help = "Set the called variable to true"
      func run(using context: ConsoleKitCommands.CommandContext, signature: Signature) throws {
        called = true
      }
    }

    let command = CallCommand()
    app.commands.use(command, as: "call")

    // Act
    try await app.cliKit()

    // Assert
    XCTAssertTrue(command.called)
  }

  func test_async_command_can_be_called() async throws {
    // Arrange
    var env: Environment = .testing
    env.commandInput = CommandInput(arguments: ["<endpoint>", "call"])
    let app = Application(env)
    defer { app.shutdown() }

    actor CallCommand: AsyncCommand {
      var called: Bool = false
      struct Signature: CommandSignature {}
      let help = "Set the called variable to true"
      func run(using context: ConsoleKitCommands.CommandContext, signature: Signature) async throws
      {
        called = true
      }
    }

    let command = CallCommand()
    app.asyncCommands.use(command, as: "call")

    // Act
    try await app.cliKit()

    // Assert
    let actual = await command.called
    XCTAssertTrue(actual)
  }
}
