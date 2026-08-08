import SwiftUI

struct MainView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Hidden button to catch Cmd+, shortcut
            Button("") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showingSettings.toggle()
                }
            }
            .keyboardShortcut(",", modifiers: .command)
            .hidden()
            .frame(width: 0, height: 0)
            
            // Compact toolbar — only on main screen when permission granted
            if permissionManager.isAccessibilityGranted {
                HStack {
                    Spacer()
                    
                    if showingSettings {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showingSettings = false
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showingSettings = true
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 30, height: 30)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            // Content
            Group {
                if !permissionManager.isAccessibilityGranted {
                    PermissionView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else if showingSettings {
                    SettingsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showingSettings = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                } else {
                    ScreenCornerView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingSettings)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: permissionManager.isAccessibilityGranted)
        }
        .frame(width: 660, height: 540)
        .background(Color(red: 0x24/255.0, green: 0x23/255.0, blue: 0x21/255.0))
        .onAppear {
            if permissionManager.isAccessibilityGranted && configStore.config.isActive {
                engine.start()
            }
        }
    }
}
