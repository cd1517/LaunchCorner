import SwiftUI
import AppKit

@MainActor
class AppState: ObservableObject {
    let configStore = ConfigStore()
    let permissionManager = PermissionManager()
    lazy var updateManager: UpdateManager = {
        UpdateManager()
    }()
    lazy var engine: CornerDetectionEngine = {
        CornerDetectionEngine(configStore: configStore)
    }()
    lazy var menuBarManager: MenuBarManager = {
        MenuBarManager(configStore: configStore)
    }()
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var appState: AppState?
    var openWindowHandler: (() -> Void)?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
    }
    
    @objc private func handleWindowWillClose(_ notification: Notification) {
        Task { @MainActor [weak self] in
            guard let closedWindow = notification.object as? NSWindow else { return }
            
            // Ignore sheets, popovers, or child windows
            if closedWindow.isSheet || closedWindow.sheetParent != nil || closedWindow.className.contains("Popover") {
                return
            }
            
            // Defer slightly so SwiftUI finishes processing window state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self, let configStore = self.appState?.configStore else { return }
                
                let hasVisibleMainWindow = NSApp.windows.contains { win in
                    win.isVisible && !win.isSheet && win.sheetParent == nil && win.level == .normal
                }
                
                if !hasVisibleMainWindow {
                    if configStore.config.showInMenuBar {
                        // Show in Menu Bar is ON: hide from Dock (.accessory) and keep running in Menu Bar
                        NSApp.setActivationPolicy(.accessory)
                    } else {
                        // Show in Menu Bar is OFF: quit app cleanly so no phantom process or Dock icon stays behind
                        NSApp.terminate(nil)
                    }
                }
            }
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }
    
    func showMainWindow() {
        Task { @MainActor [weak self] in
            NSApp.setActivationPolicy(.regular)
            
            // 1. Try visible main windows
            if let window = NSApp.windows.first(where: { win in
                win.isVisible && !win.isSheet && win.sheetParent == nil && win.level == .normal
            }) {
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            
            // 2. Try non-visible main windows
            if let window = NSApp.windows.first(where: { win in
                !win.isSheet && win.sheetParent == nil && win.level == .normal
            }) {
                window.setIsVisible(true)
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            
            // 3. Fallback: Re-open main window via SwiftUI openWindow
            self?.openWindowHandler?()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApp.windows.first(where: { !$0.isSheet && $0.sheetParent == nil }) {
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}

struct MainViewContainer: View {
    @Environment(\.openWindow) private var openWindow
    let appDelegate: AppDelegate
    
    var body: some View {
        MainView()
            .onAppear {
                appDelegate.openWindowHandler = {
                    openWindow(id: "main-window")
                }
            }
    }
}

@main
struct LaunchCornerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup("LaunchCorner", id: "main-window") {
            MainViewContainer(appDelegate: appDelegate)
                .environmentObject(appState.configStore)
                .environmentObject(appState.permissionManager)
                .environmentObject(appState.engine)
                .environmentObject(appState.updateManager)
                .onAppear {
                    appDelegate.appState = appState
                    appDelegate.showMainWindow()
                    _ = appState.menuBarManager
                    
                    let delegate = appDelegate
                    appState.menuBarManager.onOpenSettings = { [weak delegate] in
                        delegate?.showMainWindow()
                    }
                    
                    let updateManager = appState.updateManager
                    appState.menuBarManager.onCheckForUpdates = { [weak updateManager] in
                        updateManager?.checkForUpdates()
                    }
                    
                    appState.permissionManager.startMonitoringPermission()
                }
        }
        .windowResizability(.contentSize)
    }
}
