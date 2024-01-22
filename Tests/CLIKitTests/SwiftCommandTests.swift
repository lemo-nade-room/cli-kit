import SwiftCommand
import Vapor
import XCTest

@testable import CLIKit

final class SwiftCommandTests: XCTestCase {
  func test_can_file_create_and_remove() async throws {
    // Arrange
    var env: Environment = .testing
    env.commandInput = CommandInput(arguments: ["<endpoint>", "create-file", "hello.txt"])
    let app = Application(env)
    defer { app.shutdown() }

    final class CreateFileCommand: AsyncCommand {
      struct Signature: CommandSignature {
        @Argument(name: "file path", help: "The path to the file to create")
        var filePath: String
      }
      let help = "Create a file at the given path"
      func run(using context: ConsoleKitCommands.CommandContext, signature: Signature) async throws
      {
        let output = try await Command.findInPath(withName: "touch")!
          .addArgument(signature.filePath)
          .output
        assert(output.status.terminatedSuccessfully)
      }
    }

    // Act
    try await app.cliKit { app in
      app.asyncCommands.use(CreateFileCommand(), as: "create-file")
    }

    // Assert
    let fileManager = FileManager()
    XCTAssertTrue(fileManager.fileExists(atPath: "hello.txt"))
    try fileManager.removeItem(atPath: "hello.txt")
  }
}
