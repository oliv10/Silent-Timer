import XCTest
@testable import SilentStatusTimer

final class StatusDisplayModelTests: XCTestCase {
    func testIdleAndHideOffShowsIdleIconWithoutTitle() {
        let model = StatusDisplayModel.make(
            isRunning: false,
            hideCountdownInMenuBar: false,
            countdownLabel: nil
        )

        XCTAssertEqual(model.iconSymbolName, "timer")
        XCTAssertEqual(model.menuBarTitle, "")
    }

    func testIdleAndHideOnShowsIdleIconWithoutTitle() {
        let model = StatusDisplayModel.make(
            isRunning: false,
            hideCountdownInMenuBar: true,
            countdownLabel: nil
        )

        XCTAssertEqual(model.iconSymbolName, "timer")
        XCTAssertEqual(model.menuBarTitle, "")
    }

    func testRunningAndHideOffShowsRunningIconWithCountdownTitle() {
        let model = StatusDisplayModel.make(
            isRunning: true,
            hideCountdownInMenuBar: false,
            countdownLabel: "5:00"
        )

        XCTAssertEqual(model.iconSymbolName, "timer")
        XCTAssertEqual(model.menuBarTitle, " 5:00")
    }

    func testRunningAndHideOnShowsRunningIconWithoutTitle() {
        let model = StatusDisplayModel.make(
            isRunning: true,
            hideCountdownInMenuBar: true,
            countdownLabel: "5:00"
        )

        XCTAssertEqual(model.iconSymbolName, "timer")
        XCTAssertEqual(model.menuBarTitle, "")
    }
}
