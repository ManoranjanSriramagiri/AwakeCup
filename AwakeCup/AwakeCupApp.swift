import SwiftUI

@main
struct AwakeCupApp: App {
    @StateObject private var controller = AwakeController()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(controller: controller)
        } label: {
            Label(
                "AwakeCup",
                systemImage: controller.isEnabled ? "cup.and.saucer.fill" : "cup.and.saucer"
            )
        }
        .menuBarExtraStyle(.menu)
    }
}
