import Fluent
import FluentSQLiteDriver
import Vapor
import XCTest

@testable import CLIKit

final class DatabaseTests: XCTestCase {
  func test_SQLite_Database() async throws {
    // Arrange
    var env: Environment = .testing
    env.commandInput = CommandInput(arguments: ["<endpoint>", "search", "Alice"])
    let app = Application(env)
    defer { app.shutdown() }

    let console = ConsoleForTest()
    app.console = console

    app.databases.use(
      DatabaseConfigurationFactory.sqlite(.file("\(NSHomeDirectory())/clikit-test.sqlite")),
      as: .sqlite
    )

    app.migrations.add(CreateTodo())
    try await app.autoMigrate()

    let todos: [Todo] = [
      .init(title: "Bob", message: "My name is Bob!"),
      .init(title: "Alice", message: "My name is Alice!"),
      .init(title: "Eve", message: "My name is Eve!"),
    ]
    try await todos.create(on: app.db)

    final class TodoSearchCommand: AsyncCommand {
      struct Signature: CommandSignature {
        @Argument(name: "search title", help: "The title to search for")
        var searchTitle: String
      }
      let help = "Search for a todo by title"
      func run(using context: ConsoleKitCommands.CommandContext, signature: Signature) async throws
      {
        let title = signature.searchTitle
        let todos = try await Todo.query(on: context.application.db)
          .filter(\.$title == title)
          .all()
        for todo in todos {
          context.console.print("\(todo.title): \(todo.message)")
        }
      }
    }

    // Act
    try await app.cliKit { app in
      app.asyncCommands.use(TodoSearchCommand(), as: "search")
    }

    // Assert
    XCTAssertEqual(console.outputted[0].text.fragments[0].string, "Alice: My name is Alice!")
    XCTAssertTrue(console.outputted[0].newLine)
  }

  final class Todo: Model {
    static let schema = "todos"

    @ID
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "message")
    var message: String

    init() {}

    init(id: UUID? = nil, title: String, message: String) {
      self.id = id
      self.title = title
      self.message = message
    }
  }

  struct CreateTodo: AsyncMigration {
    func prepare(on database: Database) async throws {
      try await database.schema("todos")
        .id()
        .field("title", .string, .required)
        .field("message", .string, .required)
        .create()
    }
    func revert(on database: Database) async throws {
      try await database.schema("todos").delete()
    }
  }
}
