import ConsoleKit
import Foundation

public final class ConsoleForTest: Console, @unchecked Sendable {

  public var size: (width: Int, height: Int)

  public var reported: [(error: String, newLine: Bool)] = []

  public var inputted: [Bool] = []

  public var inputs: [String] = []
  private var inputCount = 0

  public var outputted: [(text: ConsoleKitTerminal.ConsoleText, newLine: Bool)] = []

  public var cleared: [ConsoleKitTerminal.ConsoleClear] = []

  public init(
    inputs: [String] = [],
    size: (width: Int, height: Int) = (width: 200, height: 100)
  ) {
    self.inputs = inputs
    self.size = size
  }

  public func input(isSecure: Bool) -> String {
    guard inputCount < inputs.count else {
      fatalError("Input count exceeded")
    }
    self.inputted.append(isSecure)
    let input = self.inputs[inputCount]
    inputCount += 1
    return input
  }

  public func report(error: String, newLine: Bool) {
    self.reported.append((error: error, newLine: newLine))
  }

  public var userInfo: [ConsoleKitTerminal.AnySendableHashable: Sendable] = [:]

  public func output(_ text: ConsoleKitTerminal.ConsoleText, newLine: Bool) {
    self.outputted.append((text: text, newLine: newLine))
  }

  public func clear(_ type: ConsoleKitTerminal.ConsoleClear) {
    self.cleared.append(type)
  }
}
