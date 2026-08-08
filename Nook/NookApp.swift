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
        DispatchQueue.main.async { [weak self] in
            if let window = NSApp.windows.first {
                window.delegate = self
            }
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if let configStore = appState?.configStore, configStore.config.showInMenuBar {
            sender.orderOut(nil)
            // Removes icon from Dock when window is closed, running purely as a Menu Bar app
            NSApp.setActivationPolicy(.accessory)
            return false
        }
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }
    
    func showMainWindow() {
        NSApp.setActivationPolicy(.regular)
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

@main
struct NookApp: App {
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
                    
                    appState.menuBarManager.onOpenSettings = { [weak appDelegate] in
                        appDelegate?.showMainWindow()
                    }
                    
                    appState.permissionManager.startMonitoringPermission()
                }
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
