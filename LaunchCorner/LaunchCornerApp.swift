import SwiftUI
import AppKit

@MainActor
class AppState: ObservableObject {
    let configStore = ConfigStore()
    let permissionManager = PermissionManager()
    lazy var engine: CornerDetectionEngine = {
        CornerDetectionEngine(configStore: configStore)
    }()
    lazy var menuBarManager: MenuBarManager = {
        MenuBarManager(configStore: configStore)
    }()
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var appState: AppState?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Observe window closing to remove icon from Dock when running in menu bar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }
    
    @objc private func handleWindowWillClose(_ notification: Notification) {
        Task { @MainActor [weak self] in
            guard let window = notification.object as? NSWindow, window.isKeyWindow || NSApp.windows.contains(window) else { return }
            
            if let configStore = self?.appState?.configStore, configStore.config.showInMenuBar {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }
    
    func showMainWindow() {
        Task { @MainActor in
            NSApp.setActivationPolicy(.regular)
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

@main
struct LaunchCornerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup("LaunchCorner") {
            MainView()
                .environmentObject(appState.configStore)
                .environmentObject(appState.permissionManager)
                .environmentObject(appState.engine)
                .onAppear {
                    appDelegate.appState = appState
                    _ = appState.menuBarManager
                    
                    let delegate = appDelegate
                    appState.menuBarManager.onOpenSettings = { [weak delegate] in
                        delegate?.showMainWindow()
                    }
                    
                    appState.permissionManager.startMonitoringPermission()
                }
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
