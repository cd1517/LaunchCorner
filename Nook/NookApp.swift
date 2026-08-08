import SwiftUI

@MainActor
class AppState: ObservableObject {
    let configStore = ConfigStore()
    let permissionManager = PermissionManager()
    lazy var engine: CornerDetectionEngine = {
        CornerDetectionEngine(configStore: configStore)
    }()
}

@main
struct NookApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup("Nook") {
            MainView()
                .environmentObject(appState.configStore)
                .environmentObject(appState.permissionManager)
                .environmentObject(appState.engine)
                .onAppear {
                    appState.permissionManager.startMonitoringPermission()
                }
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
        
        // Cmd+, opens Settings
        Settings {
            SettingsView()
                .environmentObject(appState.configStore)
                .preferredColorScheme(.dark)
        }
    }
}
