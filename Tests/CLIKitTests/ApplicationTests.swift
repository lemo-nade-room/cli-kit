import ConsoleKit
import XCTest

@testable import CLIKit

final class ApplicationTests: XCTestCase {
  func test_command_can_be_called() async throws {
    // Arrange
    var app = Application(env: .testing)

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
    try await app.execute(arguments: ["<endpoint>", "call"])

    // Assert
    XCTAssertTrue(command.called)
  }

  func test_async_command_can_be_called() async throws {
    // Arrange
    var app = Application(env: .testing)

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
    try await app.execute(arguments: ["<endpoint>", "call"])

    // Assert
    let actual = await command.called
    XCTAssertTrue(actual)
  }
}
