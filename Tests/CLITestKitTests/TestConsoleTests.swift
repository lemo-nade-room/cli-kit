import CLITestKit
import Testing

@Suite struct TestConsoleTests {
    @Test func 入出力が確認できる() {
        // Arrange
        let console = TestConsole(inputQueue: ["Alice", "password"])

        // Act
        let username = console.input(isSecure: false)
        let password = console.input(isSecure: true)
        console.clear(.screen)
        console.output("Hello, My first CLI!!", newLine: true)
        console.output("Your username is", newLine: false)
        console.success("Alice", newLine: true)
        console.error("But your Password is unauthorized!!", newLine: true)
        console.report(error: "Unauthorized", newLine: true)
        console.warning("Oh no!!!!", newLine: true)

        // Assert
        #expect(username == "Alice")
        #expect(password == "password")
        #expect(console.records == [
            .input(secure: false, returning: "Alice"),
            .input(secure: true, returning: "password"),
            .clear(type: .screen),
            .output(text: "Hello, My first CLI!!", newLine: true, style: .plain),
            .output(text: "Your username is", newLine: false, style: .plain),
            .output(text: "Alice", newLine: true, style: .success),
            .output(text: "But your Password is unauthorized!!", newLine: true, style: .error),
            .report(error: "Unauthorized", newLine: true),
            .output(text: "Oh no!!!!", newLine: true, style: .warning),
        ])
    }
}
