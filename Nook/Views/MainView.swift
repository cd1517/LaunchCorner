import SwiftUI

struct MainView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Toolbar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "macwindow")
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .font(.title2)
                    Text("Nook")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Status Indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                            .shadow(color: statusColor.opacity(0.5), radius: 4)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .cornerRadius(16)
                    
                    Button(action: {
                        configStore.config.isActive.toggle()
                        configStore.save()
                        if configStore.config.isActive {
                            engine.start()
                        } else {
                            engine.stop()
                        }
                    }) {
                        Image(systemName: configStore.config.isActive ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(configStore.config.isActive ? .yellow : .green)
                    }
                    .buttonStyle(.plain)
                    .disabled(!permissionManager.isAccessibilityGranted)
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
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
    
    private var statusColor: Color {
        if !permissionManager.isAccessibilityGranted {
            return .red
        } else if !configStore.config.isActive {
            return .yellow
        } else {
            return .green
        }
    }
    
    private var statusText: String {
        if !permissionManager.isAccessibilityGranted {
            return "No Permission"
        } else if !configStore.config.isActive {
            return "Paused"
        } else {
            return "Active"
        }
    }
}
