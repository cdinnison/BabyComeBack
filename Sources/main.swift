import AppKit
import Foundation

class BabyComeBackApp: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var waitingSessions: Set<String> = []
    private var pulseTimer: Timer?
    private var blinkOn = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()
        setupMenu()
        registerForNotifications()

        NSLog("BabyComeBack: Running. Listening for Claude notifications...")
    }

    private func setupMenu() {
        let menu = NSMenu()

        let statusMenuItem = NSMenuItem(title: "No Claude instances waiting", action: nil, keyEquivalent: "")
        statusMenuItem.tag = 100
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        let clearItem = NSMenuItem(title: "Clear All", action: #selector(clearAll), keyEquivalent: "c")
        clearItem.target = self
        menu.addItem(clearItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func registerForNotifications() {
        let center = DistributedNotificationCenter.default()

        // Claude needs attention (permission_prompt, idle_prompt)
        center.addObserver(
            self,
            selector: #selector(handleNeedsAttention(_:)),
            name: NSNotification.Name("com.claude.needsAttention"),
            object: nil
        )

        // Claude resumed (user responded, or Stop event)
        center.addObserver(
            self,
            selector: #selector(handleResumed(_:)),
            name: NSNotification.Name("com.claude.resumed"),
            object: nil
        )
    }

    @objc private func handleNeedsAttention(_ notification: Notification) {
        let sessionId = notification.userInfo?["sessionId"] as? String ?? UUID().uuidString
        let message = notification.userInfo?["message"] as? String ?? "Claude needs attention"

        NSLog("BabyComeBack: Needs attention - session: %@, message: %@", sessionId, message)

        DispatchQueue.main.async {
            self.waitingSessions.insert(sessionId)
            self.updateIcon()
            self.updateStatusMenuItem()
        }
    }

    @objc private func handleResumed(_ notification: Notification) {
        let sessionId = notification.userInfo?["sessionId"] as? String

        NSLog("BabyComeBack: Resumed - session: %@", sessionId ?? "all")

        DispatchQueue.main.async {
            if let sessionId = sessionId, !sessionId.isEmpty {
                self.waitingSessions.remove(sessionId)
            } else {
                self.waitingSessions.removeAll()
            }
            self.updateIcon()
            self.updateStatusMenuItem()
        }
    }

    private func updateIcon() {
        let isWaiting = !waitingSessions.isEmpty

        if isWaiting {
            startPulsing()
        } else {
            stopPulsing()
        }

        renderIcon()
    }

    private func renderIcon() {
        guard let button = statusItem.button else { return }

        let symbol: String
        let color: NSColor

        if waitingSessions.isEmpty {
            symbol = "▪"  // Small square when idle
            color = .tertiaryLabelColor
        } else {
            // Blinking terminal cursor
            symbol = blinkOn ? "█" : " "
            color = NSColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)  // Construction orange
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        ]
        button.attributedTitle = NSAttributedString(string: symbol, attributes: attributes)
    }

    private func startPulsing() {
        guard pulseTimer == nil else { return }

        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.blinkOn.toggle()
            self.renderIcon()
        }
    }

    private func stopPulsing() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        blinkOn = true
    }

    private func updateStatusMenuItem() {
        guard let menu = statusItem.menu,
              let statusItem = menu.item(withTag: 100) else { return }

        let count = waitingSessions.count
        if count == 0 {
            statusItem.title = "No Claude instances waiting"
        } else if count == 1 {
            statusItem.title = "1 Claude instance waiting"
        } else {
            statusItem.title = "\(count) Claude instances waiting"
        }
    }

    @objc private func clearAll() {
        waitingSessions.removeAll()
        updateIcon()
        updateStatusMenuItem()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// App entry point
let app = NSApplication.shared
let delegate = BabyComeBackApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)  // Menu bar only, no dock icon
app.run()
