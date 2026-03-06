import SwiftUI
import AppKit

struct MenuContentView: View {
    @ObservedObject var controller: AwakeController

    private struct DurationOption: Identifiable {
        let minutes: Int
        let title: String
        var id: Int { minutes }
    }

    private let durationOptions: [DurationOption] = [
        .init(minutes: 0, title: "Indefinitely"),
        .init(minutes: 5, title: "5 minutes"),
        .init(minutes: 15, title: "15 minutes"),
        .init(minutes: 30, title: "30 minutes"),
        .init(minutes: 60, title: "1 hour"),
        .init(minutes: 120, title: "2 hours")
    ]

    var body: some View {
        Button(controller.isEnabled ? "Disable" : "Keep Awake") {
            controller.toggleEnabled()
        }
        .keyboardShortcut(.space, modifiers: [])

        Menu("Duration") {
            ForEach(durationOptions) { option in
                Button {
                    controller.setDurationMinutes(option.minutes)
                    if !controller.isEnabled {
                        controller.setEnabled(true, durationMinutes: option.minutes)
                    }
                } label: {
                    if controller.durationMinutes == option.minutes {
                        Text("✓ \(option.title)")
                    } else {
                        Text(option.title)
                    }
                }
            }
        }

        if controller.isEnabled, let remaining = controller.remainingSeconds {
            Divider()
            Text("Remaining: \(format(seconds: remaining))")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
        }

        Divider()

        Toggle("Launch at login", isOn: $controller.launchAtLogin)

        if let err = controller.lastError, !err.isEmpty {
            Divider()
            Text(err)
                .font(.system(size: 12))
                .foregroundStyle(.red)
                .fixedSize(horizontal: false, vertical: true)
        }

        Divider()

        Button("About AwakeCup") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.orderFrontStandardAboutPanel(nil)
        }

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func format(seconds: Int) -> String {
        let s = max(0, seconds)
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }
}
