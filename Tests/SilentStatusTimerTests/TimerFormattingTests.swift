import XCTest
@testable import SilentStatusTimer

final class TimerFormattingTests: XCTestCase {
    func testFormatsZeroSeconds() {
        XCTAssertEqual(TimerFormatting.format(seconds: 0), "00:00:00")
    }

    func testFormatsSubMinuteValue() {
        XCTAssertEqual(TimerFormatting.format(seconds: 59), "00:00:59")
    }

    func testFormatsMultiHourValue() {
        XCTAssertEqual(TimerFormatting.format(seconds: 3661), "01:01:01")
    }

    func testClampsNegativeSecondsToZero() {
        XCTAssertEqual(TimerFormatting.format(seconds: -42), "00:00:00")
    }
}
