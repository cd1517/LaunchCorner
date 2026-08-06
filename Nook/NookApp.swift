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
        WindowGroup {
            MainView()
                .environmentObject(appState.configStore)
                .environmentObject(appState.permissionManager)
                .environmentObject(appState.engine)
                .onAppear {
                    appState.permissionManager.startMonitoringPermission()
                }
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
