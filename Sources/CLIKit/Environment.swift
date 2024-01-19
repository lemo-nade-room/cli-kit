import ConsoleKit
import Foundation

public struct Environment: Sendable, Hashable {

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public static func detect(arguments: [String] = ProcessInfo.processInfo.arguments) throws
    -> Environment
  {
    var commandInput = CommandInput(arguments: arguments)
    return try Environment.detect(from: &commandInput)
  }

  public static func detect(from commandInput: inout CommandInput) throws -> Environment {
    struct EnvironmentSignature: CommandSignature {
      @Option(name: "env", short: "e", help: "Change the application's environment")
      var environment: String?
    }

    var env: Environment
    switch try EnvironmentSignature(from: &commandInput).environment {
    case "prod", "production": env = .production
    case "dev", "development", .none: env = .development
    case "test", "testing": env = .testing
    case .some(let custom): env = .init(name: custom)
    default: env = .production
    }
    return env
  }

  public static var production: Environment { .init(name: "production") }

  /// An environment for developing your application.
  public static var development: Environment { .init(name: "development") }

  public static var testing: Environment { .init(name: "testing") }
}
