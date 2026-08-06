import SwiftUI

struct MainView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact toolbar — only on main screen
            if permissionManager.isAccessibilityGranted {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
            
            // Content
            Group {
                if !permissionManager.isAccessibilityGranted {
                    PermissionView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    ScreenCornerView()
                        .transition(.opacity.combined(with: .scale(scale: 1.05)))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: permissionManager.isAccessibilityGranted)
        }
        .frame(width: 660, height: 500)
        .background(Color(NSColor.underPageBackgroundColor))
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            if permissionManager.isAccessibilityGranted && configStore.config.isActive {
                engine.start()
            }
        }
    }
}
