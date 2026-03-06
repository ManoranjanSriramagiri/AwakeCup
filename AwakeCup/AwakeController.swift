import Foundation
import SwiftUI
import ServiceManagement

@MainActor
final class AwakeController: ObservableObject {
    @AppStorage("AwakeCup.isEnabled") private var isEnabledStored: Bool = false
    @AppStorage("AwakeCup.durationMinutes") private var durationMinutesStored: Int = 0
    @AppStorage("AwakeCup.launchAtLogin") var launchAtLogin: Bool = false {
        didSet { updateLaunchAtLogin() }
    }

    @Published private(set) var isEnabled: Bool = false
    @Published var durationMinutes: Int = 0
    @Published private(set) var remainingSeconds: Int? = nil
    @Published private(set) var lastError: String? = nil

    private let assertion = PowerAssertion(reason: "AwakeCup — Keep this Mac awake")
    private var disableTimer: Timer?
    private var countdownTimer: Timer?
    private var endDate: Date?

    init() {
        isEnabled = isEnabledStored
        durationMinutes = durationMinutesStored

        if isEnabled {
            // Best-effort re-enable on app start.
            setEnabled(true, durationMinutes: durationMinutes)
        }
    }

    func toggleEnabled() {
        setEnabled(!isEnabled, durationMinutes: durationMinutes)
    }

    func setDurationMinutes(_ minutes: Int) {
        durationMinutes = minutes
        durationMinutesStored = minutes

        // If currently enabled, re-arm the timer using the new duration.
        if isEnabled {
            armAutoDisableTimer(minutes: minutes)
        }
    }

    func setEnabled(_ enabled: Bool, durationMinutes: Int) {
        lastError = nil

        if enabled {
            do {
                try assertion.enable(preventDisplaySleep: true)
                isEnabled = true
                isEnabledStored = true
                armAutoDisableTimer(minutes: durationMinutes)
            } catch {
                isEnabled = false
                isEnabledStored = false
                disarmTimers()
                lastError = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            }
        } else {
            assertion.disable()
            isEnabled = false
            isEnabledStored = false
            disarmTimers()
        }
    }

    private func armAutoDisableTimer(minutes: Int) {
        disarmTimers()

        guard minutes > 0 else {
            endDate = nil
            remainingSeconds = nil
            return
        }

        let seconds = minutes * 60
        let end = Date().addingTimeInterval(TimeInterval(seconds))
        endDate = end
        remainingSeconds = seconds

        disableTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.setEnabled(false, durationMinutes: 0)
            }
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateRemainingTime()
            }
        }
    }

    private func updateRemainingTime() {
        guard let endDate else { return }
        let remaining = Int(endDate.timeIntervalSinceNow.rounded(.down))
        remainingSeconds = max(0, remaining)
        if remaining <= 0 {
            disarmTimers()
        }
    }

    private func disarmTimers() {
        disableTimer?.invalidate()
        disableTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        endDate = nil
        remainingSeconds = nil
    }

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            lastError = "Launch at login failed: \(error.localizedDescription)"
        }
    }
}
