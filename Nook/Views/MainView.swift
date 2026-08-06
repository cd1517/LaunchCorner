import SwiftUI

struct MainView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimal Toolbar — settings gear only
            HStack {
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
            .background(.ultraThinMaterial)
            
            Divider()
            
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
        .frame(minWidth: 600, minHeight: 480)
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
