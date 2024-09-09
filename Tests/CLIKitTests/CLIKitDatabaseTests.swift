import CLIKit
import ConsoleKit
import Fluent
import Foundation
import Testing

@Suite struct CLIKitDatabaseTests {
    @Test func SQLiteデータベースを使用可能() async throws {
        // Arrange
        final class Store: Model, @unchecked Sendable, CustomStringConvertible {
            static let schema = "key_values"
            @ID(key: .id) var id: UUID?
            @Field(key: "key") var key: String
            @Field(key: "value") var value: String
            init() { }
            init(key: String, value: String) {
                self.key = key
                self.value = value
            }
            var description: String {
                "key: \(key), value: \(value)"
            }
        }

        struct TestCommand: AsyncCommand {
            struct Signature: CommandSignature {}
            let help = "save command"
            func run(using context: CommandContext, signature: Signature) async throws {
                try await Store(key: "Hello", value: "World").create(on: context.db)
                let all = try await Store.query(on: context.db).all()
                context.console.output("\(all.map(\.description).joined())", newLine: true)
            }
        }

        let console = TestConsole()
        let sqliteURL = FileManager().homeDirectoryForCurrentUser.appendingPathComponent("test.sqlite")
        func removeSQLiteFile() {
            do { try FileManager().removeItem(at: sqliteURL) } catch {}
        }
        removeSQLiteFile()
        defer { removeSQLiteFile() }
        var sut = CLI(
            console: console,
            input: CommandInput(arguments: ["cli", "save"]),
            sqliteURL: sqliteURL
        )
        sut.use(TestCommand(), as: "save")
        sut.migrations.add(StoreMigration())

        // Act
        await sut.run()

        // Assert
        #expect(console.testOutputQueue == ["key: Hello, value: World\n"])
    }

    struct StoreMigration: AsyncMigration {
        func prepare(on database: any Database) async throws {
            try await database.schema("key_values")
                .id()
                .field("key", .string, .required)
                .field("value", .string, .required)
                .unique(on: "key")
                .create()
        }
        func revert(on database: any Database) async throws {
            try await database.schema("key_values").delete()
        }
    }
}
