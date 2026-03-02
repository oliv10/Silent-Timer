import AppKit

final class FixedRangeNumberFormatter: Formatter {
    private let maxValue: Int

    init(maxValue: Int) {
        self.maxValue = maxValue
        super.init()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else {
            return nil
        }
        let value = min(maxValue, max(0, number.intValue))
        return String(format: "%02d", value)
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if string.isEmpty {
            obj?.pointee = NSNumber(value: 0)
            return true
        }

        guard let value = Int(string), (0...maxValue).contains(value) else {
            return false
        }
        obj?.pointee = NSNumber(value: value)
        return true
    }

    override func isPartialStringValid(
        _ partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if partialString.isEmpty {
            return true
        }
        if partialString.count > 2 {
            return false
        }
        return partialString.allSatisfy(\.isNumber)
    }
}

@MainActor
final class CustomTimerPanelController: NSObject, NSTextFieldDelegate {
    private let panel: NSPanel
    private let hoursField = NSTextField(string: "00")
    private let minutesField = NSTextField(string: "05")
    private let secondsField = NSTextField(string: "00")

    private var hours = 0 {
        didSet {
            hours = max(0, min(23, hours))
            hoursField.stringValue = String(format: "%02d", hours)
        }
    }
    private var minutes = 5 {
        didSet {
            minutes = max(0, min(59, minutes))
            minutesField.stringValue = String(format: "%02d", minutes)
        }
    }
    private var seconds = 0 {
        didSet {
            seconds = max(0, min(59, seconds))
            secondsField.stringValue = String(format: "%02d", seconds)
        }
    }

    override init() {
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 780, height: 460),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init()
        configurePanel()
        buildUI()
    }

    func runModal() -> Int? {
        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        let result = NSApp.runModal(for: panel)
        panel.orderOut(nil)

        guard result == .OK else {
            return nil
        }

        let total = hours * 3600 + minutes * 60 + seconds
        return total > 0 ? total : nil
    }

    private func configurePanel() {
        panel.title = "Custom Timer"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.isReleasedWhenClosed = false
    }

    private func buildUI() {
        guard let contentView = panel.contentView else {
            return
        }

        let backdrop = NSVisualEffectView()
        backdrop.material = .underWindowBackground
        backdrop.blendingMode = .behindWindow
        backdrop.state = .active
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backdrop)

        let glassCard = NSVisualEffectView()
        glassCard.material = .hudWindow
        glassCard.blendingMode = .withinWindow
        glassCard.state = .active
        glassCard.translatesAutoresizingMaskIntoConstraints = false
        glassCard.wantsLayer = true
        glassCard.layer?.cornerRadius = 28
        glassCard.layer?.borderWidth = 1
        glassCard.layer?.borderColor = NSColor.white.withAlphaComponent(0.25).cgColor
        contentView.addSubview(glassCard)

        let titleLabel = NSTextField(labelWithString: "Set Timer")
        titleLabel.font = NSFont.systemFont(ofSize: 26, weight: .semibold)
        titleLabel.textColor = NSColor.white.withAlphaComponent(0.88)
        titleLabel.alignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let timerStack = NSStackView()
        timerStack.orientation = .horizontal
        timerStack.alignment = .centerY
        timerStack.spacing = 14
        timerStack.translatesAutoresizingMaskIntoConstraints = false

        let colonOne = makeColonLabel()
        let colonTwo = makeColonLabel()
        let hoursGroup = makeTimeGroup(label: "hr", valueField: hoursField)
        let minutesGroup = makeTimeGroup(label: "min", valueField: minutesField)
        let secondsGroup = makeTimeGroup(label: "sec", valueField: secondsField)

        timerStack.addArrangedSubview(hoursGroup)
        timerStack.addArrangedSubview(colonOne)
        timerStack.addArrangedSubview(minutesGroup)
        timerStack.addArrangedSubview(colonTwo)
        timerStack.addArrangedSubview(secondsGroup)

        let cancelButton = makeActionButton(
            title: "Cancel",
            color: NSColor.white.withAlphaComponent(0.12),
            borderColor: NSColor.white.withAlphaComponent(0.18),
            textColor: NSColor.white.withAlphaComponent(0.82)
        )
        cancelButton.target = self
        cancelButton.action = #selector(cancelAction)

        let startButton = makeActionButton(
            title: "Start",
            color: NSColor(calibratedRed: 0.22, green: 0.79, blue: 0.34, alpha: 1),
            borderColor: NSColor(calibratedRed: 0.41, green: 0.93, blue: 0.50, alpha: 0.95),
            textColor: .white
        )
        startButton.target = self
        startButton.action = #selector(startAction)
        startButton.keyEquivalent = "\r"

        let buttonStack = NSStackView(views: [cancelButton, startButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        glassCard.addSubview(titleLabel)
        glassCard.addSubview(timerStack)
        glassCard.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            glassCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            glassCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            glassCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            glassCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            titleLabel.topAnchor.constraint(equalTo: glassCard.topAnchor, constant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: glassCard.centerXAnchor),

            timerStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            timerStack.centerXAnchor.constraint(equalTo: glassCard.centerXAnchor),

            buttonStack.leadingAnchor.constraint(equalTo: glassCard.leadingAnchor, constant: 88),
            buttonStack.trailingAnchor.constraint(equalTo: glassCard.trailingAnchor, constant: -88),
            buttonStack.bottomAnchor.constraint(equalTo: glassCard.bottomAnchor, constant: -28),
            buttonStack.heightAnchor.constraint(equalToConstant: 56),
        ])

        configureTextFields()
    }

    private func makeTimeGroup(label: String, valueField: NSTextField) -> NSStackView {
        let unitLabel = NSTextField(labelWithString: label)
        unitLabel.textColor = NSColor.white.withAlphaComponent(0.55)
        unitLabel.font = NSFont.systemFont(ofSize: 20, weight: .medium)
        unitLabel.alignment = .center

        valueField.textColor = NSColor.white.withAlphaComponent(0.92)
        valueField.font = NSFont.monospacedDigitSystemFont(ofSize: 118, weight: .ultraLight)
        valueField.alignment = .center
        valueField.translatesAutoresizingMaskIntoConstraints = false
        valueField.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let stack = NSStackView(views: [unitLabel, valueField])
        stack.orientation = .vertical
        stack.spacing = 6
        stack.alignment = .centerX
        return stack
    }

    private func makeColonLabel() -> NSTextField {
        let label = NSTextField(labelWithString: ":")
        label.textColor = NSColor.white.withAlphaComponent(0.85)
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 110, weight: .ultraLight)
        return label
    }

    private func makeActionButton(title: String, color: NSColor, borderColor: NSColor, textColor: NSColor) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = color.cgColor
        button.layer?.borderColor = borderColor.cgColor
        button.layer?.borderWidth = 1
        button.layer?.cornerRadius = 24
        button.layer?.masksToBounds = true
        button.font = NSFont.systemFont(ofSize: 27, weight: .semibold)
        button.contentTintColor = textColor
        return button
    }

    private func configureTextFields() {
        configureTimeField(hoursField, maxValue: 23)
        configureTimeField(minutesField, maxValue: 59)
        configureTimeField(secondsField, maxValue: 59)
    }

    private func configureTimeField(_ field: NSTextField, maxValue: Int) {
        field.isEditable = true
        field.isSelectable = true
        field.isBezeled = false
        field.focusRingType = .none
        field.drawsBackground = false
        field.backgroundColor = .clear
        field.lineBreakMode = .byClipping
        field.maximumNumberOfLines = 1
        field.alignment = .center
        field.formatter = FixedRangeNumberFormatter(maxValue: maxValue)
        field.delegate = self
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        if let field = obj.object as? NSTextField {
            if field == hoursField {
                hours = parse(field: hoursField, fallback: hours, maxValue: 23)
            } else if field == minutesField {
                minutes = parse(field: minutesField, fallback: minutes, maxValue: 59)
            } else if field == secondsField {
                seconds = parse(field: secondsField, fallback: seconds, maxValue: 59)
            }
        }
    }

    private func parse(field: NSTextField, fallback: Int, maxValue: Int) -> Int {
        let raw = field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(raw) else {
            return fallback
        }
        return min(maxValue, max(0, value))
    }

    @objc private func cancelAction() {
        NSApp.stopModal(withCode: .cancel)
    }

    @objc private func startAction() {
        NSApp.stopModal(withCode: .OK)
    }
}

@MainActor
final class StatusTimerApp: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()

    private var timer: Timer?
    private var endDate: Date?

    private let statusMenuItem = NSMenuItem(title: "No timer running", action: nil, keyEquivalent: "")
    private let stopMenuItem = NSMenuItem(title: "Stop Timer", action: #selector(stopTimerAction), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItem()
        configureMenu()
        updateUI()
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }
        let icon = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timer")
        icon?.isTemplate = true
        button.image = icon
        button.title = ""
        statusItem.menu = menu
    }

    private func configureMenu() {
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())

        addPresetMenuItem(title: "Start 5 Minutes", seconds: 5 * 60)
        addPresetMenuItem(title: "Start 15 Minutes", seconds: 15 * 60)
        addPresetMenuItem(title: "Start 30 Minutes", seconds: 30 * 60)
        addPresetMenuItem(title: "Start 1 Hour", seconds: 60 * 60)

        let customItem = NSMenuItem(title: "Custom Timer...", action: #selector(startCustomTimerAction), keyEquivalent: "")
        customItem.target = self
        menu.addItem(customItem)

        stopMenuItem.target = self
        menu.addItem(stopMenuItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    private func addPresetMenuItem(title: String, seconds: Int) {
        let item = NSMenuItem(title: title, action: #selector(startPresetTimerAction(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = seconds
        menu.addItem(item)
    }

    @objc private func startPresetTimerAction(_ sender: NSMenuItem) {
        guard let seconds = sender.representedObject as? Int else {
            return
        }
        startTimer(seconds: seconds)
    }

    @objc private func startCustomTimerAction() {
        let controller = CustomTimerPanelController()
        guard let seconds = controller.runModal() else {
            return
        }
        startTimer(seconds: seconds)
    }

    @objc private func stopTimerAction() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        updateUI()
    }

    @objc private func quitAction() {
        NSApp.terminate(nil)
    }

    private func startTimer(seconds: Int) {
        timer?.invalidate()
        endDate = Date().addingTimeInterval(TimeInterval(seconds))

        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(tickTimerAction),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: .common)
        updateUI()
    }

    @objc private func tickTimerAction() {
        tick()
    }

    private func tick() {
        guard let endDate else {
            stopTimerAction()
            return
        }

        if Date() >= endDate {
            stopTimerAction()
            showFinishedAlert()
            return
        }
        updateUI()
    }

    private func updateUI() {
        guard let button = statusItem.button else {
            return
        }

        guard let endDate else {
            button.title = ""
            statusMenuItem.title = "No timer running"
            stopMenuItem.isEnabled = false
            return
        }

        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded(.down)))
        let label = TimerFormatting.format(seconds: remaining)
        button.title = " \(label)"
        statusMenuItem.title = "Running: \(label) remaining"
        stopMenuItem.isEnabled = true
    }

    private func showFinishedAlert() {
        let alert = NSAlert()
        alert.messageText = "Silent Timer"
        alert.informativeText = "Time is up."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    private func showError(message: String) {
        let alert = NSAlert()
        alert.messageText = "Silent Timer"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = StatusTimerApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
