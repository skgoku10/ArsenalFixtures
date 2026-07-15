import SwiftUI
import AppKit

@main
struct ArsenalFixturesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel: FixturesViewModel

    init() {
        let model = FixturesViewModel()
        _viewModel = StateObject(wrappedValue: model)
        // MenuBarExtra's content is built lazily on first click, so starting the poller
        // here (rather than that view's onAppear) means the menu bar title and data are
        // already fresh even if the user never opens the dropdown.
        model.start()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "soccerball")
                Text(menuBarTitle)
            }
        }
        .menuBarExtraStyle(.window)

        // A real window, not a .sheet inside the MenuBarExtra panel: MenuBarExtra's
        // .window style is a non-activating panel, so sheets presented inside it
        // often can't become key window and silently refuse keyboard input.
        Window("Arsenal Fixtures Settings", id: "settings") {
            SettingsView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
    }

    private var menuBarTitle: String {
        if let live = viewModel.liveFixture {
            return live.scoreText
        }
        return "ARS"
    }
}

/// Runs without an Info.plist (this is a Swift Package executable), so the
/// dock-icon-hiding activation policy is set here in code instead of via LSUIElement.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
