import ConsoleKit
import Foundation
import NIOConcurrencyHelpers

final class TestConsole: Console {
    // swiftlint:disable:next all
    let _testInputQueue: NIOLockedValueBox<[String]> = NIOLockedValueBox([])

    var testInputQueue: [String] {
        get { self._testInputQueue.withLockedValue { $0 } }
        set { self._testInputQueue.withLockedValue { $0 = newValue } }
    }

    // swiftlint:disable:next all
    let _testOutputQueue: NIOLockedValueBox<[String]> = NIOLockedValueBox([])
    var testOutputQueue: [String] {
        get { self._testOutputQueue.withLockedValue { $0 } }
        set { self._testOutputQueue.withLockedValue { $0 = newValue } }
    }

    // swiftlint:disable:next all
    let _userInfo: NIOLockedValueBox<[AnySendableHashable: any Sendable]> = NIOLockedValueBox([:])
    var userInfo: [AnySendableHashable: any Sendable] {
        get { self._userInfo.withLockedValue { $0 } }
        set { self._userInfo.withLockedValue { $0 = newValue } }
    }

    init() {
        self.testInputQueue = []
        self.testOutputQueue = []
        self.userInfo = [:]
    }

    func input(isSecure: Bool) -> String {
        return testInputQueue.popLast() ?? ""
    }

    func output(_ text: ConsoleText, newLine: Bool) {
        testOutputQueue.insert(text.description + (newLine ? "\n" : ""), at: 0)
    }

    func report(error: String, newLine: Bool) {}

    func clear(_ type: ConsoleClear) {}

    var size: (width: Int, height: Int) { (width: 0, height: 0) }
}
