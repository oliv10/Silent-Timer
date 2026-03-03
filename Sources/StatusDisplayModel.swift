import Foundation

struct StatusDisplayModel {
    let iconSymbolName: String
    let menuBarTitle: String

    static func make(isRunning: Bool, hideCountdownInMenuBar: Bool, countdownLabel: String?) -> StatusDisplayModel {
        let iconSymbolName = isRunning ? "clock.fill" : "timer"

        guard isRunning, hideCountdownInMenuBar == false, let countdownLabel else {
            return StatusDisplayModel(iconSymbolName: iconSymbolName, menuBarTitle: "")
        }

        return StatusDisplayModel(iconSymbolName: iconSymbolName, menuBarTitle: " \(countdownLabel)")
    }
}
