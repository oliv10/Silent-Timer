import XCTest
@testable import SilentStatusTimer

final class TimerFormattingTests: XCTestCase {
    func testFormatsZeroSeconds() {
        XCTAssertEqual(TimerFormatting.format(seconds: 0), "0:00")
    }

    func testFormatsSubMinuteValue() {
        XCTAssertEqual(TimerFormatting.format(seconds: 59), "0:59")
    }

    func testFormatsMultiHourValue() {
        XCTAssertEqual(TimerFormatting.format(seconds: 3661), "1:01:01")
    }

    func testClampsNegativeSecondsToZero() {
        XCTAssertEqual(TimerFormatting.format(seconds: -42), "0:00")
    }

    func testFormatsOneMinute() {
        XCTAssertEqual(TimerFormatting.format(seconds: 60), "1:00")
    }

    func testFormatsLastSecondBeforeOneHour() {
        XCTAssertEqual(TimerFormatting.format(seconds: 3599), "59:59")
    }

    func testFormatsExactlyOneHour() {
        XCTAssertEqual(TimerFormatting.format(seconds: 3600), "1:00:00")
    }

    func testFormatsOneHourAndOneSecond() {
        XCTAssertEqual(TimerFormatting.format(seconds: 3601), "1:00:01")
    }
}
