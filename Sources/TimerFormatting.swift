import Foundation

enum TimerFormatting {
    static func format(seconds: Int) -> String {
        let clampedSeconds = max(0, seconds)
        let hours = clampedSeconds / 3600
        let minutes = (clampedSeconds % 3600) / 60
        let secs = clampedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
