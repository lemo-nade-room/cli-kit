import CLIKit
import ConsoleKit
import Testing

@Suite struct CLITests {
    @Test func サンプル() async throws {
        // Arrange
        struct TestCommand: AsyncCommand {
            struct Signature: CommandSignature {
                @Option(name: "message", short: "m")
                var message: String?
            }
            let help = "testing command"
            func run(using context: CommandContext, signature: Signature) async throws {
                context.console.output("message: \(signature.message ?? "none")", newLine: true)
            }
        }

        let console = TestConsole()
        var sut = CLI(
            console: console,
            input: CommandInput(arguments: ["git", "commit", "-m", "hello"])
        )
        sut.use(TestCommand(), as: "commit")

        // Act
        await sut.run()

        // Assert
        #expect(console.testOutputQueue == ["message: hello\n"])
    }
}
