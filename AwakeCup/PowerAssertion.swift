import Foundation
import IOKit.pwr_mgt

enum PowerAssertionError: Error, LocalizedError {
    case iokitError(IOReturn, type: String)

    var errorDescription: String? {
        switch self {
        case let .iokitError(code, type):
            return "IOKit error \(code) while creating assertion: \(type)"
        }
    }
}

/// Thin wrapper around IOPM "no sleep" assertions.
final class PowerAssertion {
    private var assertionIDs: [IOPMAssertionID] = []
    private let reason: String

    init(reason: String) {
        self.reason = reason
    }

    var isEnabled: Bool { !assertionIDs.isEmpty }

    func enable(preventDisplaySleep: Bool = true) throws {
        guard assertionIDs.isEmpty else { return }

        try createAssertion(type: kIOPMAssertionTypePreventUserIdleSystemSleep)
        if preventDisplaySleep {
            try createAssertion(type: kIOPMAssertionTypePreventUserIdleDisplaySleep)
        }
    }

    func disable() {
        for id in assertionIDs {
            IOPMAssertionRelease(id)
        }
        assertionIDs.removeAll(keepingCapacity: false)
    }

    deinit {
        disable()
    }

    private func createAssertion(type: String) throws {
        var assertionID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            type as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )

        guard result == kIOReturnSuccess else {
            throw PowerAssertionError.iokitError(result, type: type)
        }

        assertionIDs.append(assertionID)
    }
}
