import SwiftUI

struct ScreenCornerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var selectedScreenID: String? = nil
    @State private var activeSheet: Corner? = nil
    
    private let imageSize: CGFloat = 460
    
    var body: some View {
        VStack(spacing: 12) {
            if NSScreen.screens.count > 1 {
                Picker("Monitor", selection: $selectedScreenID) {
                    Text("All Screens").tag(String?.none)
                    ForEach(NSScreen.screens, id: \.self) { screen in
                        Text(screen.localizedName).tag(String?.some(screen.localizedName))
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 250)
            }
            
            ZStack {
                // MacBook image as background
                Image("mac-screen")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                
                // Corner buttons moved out away from the MacBook screen to the left and right sides
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        CornerButton(corner: .topLeft, screenID: selectedScreenID) {
                            activeSheet = .topLeft
                        }
                        Spacer()
                        CornerButton(corner: .topRight, screenID: selectedScreenID) {
                            activeSheet = .topRight
                        }
                    }
                    Spacer()
                    HStack(spacing: 0) {
                        CornerButton(corner: .bottomLeft, screenID: selectedScreenID) {
                            activeSheet = .bottomLeft
                        }
                        Spacer()
                        CornerButton(corner: .bottomRight, screenID: selectedScreenID) {
                            activeSheet = .bottomRight
                        }
                    }
                }
                // Top padding 0.350 aligns top buttons with top corners of display
                // Horizontal padding 0.050 moves buttons far out to the left and right sides away from screen
                .padding(.top, imageSize * 0.350)
                .padding(.bottom, imageSize * 0.160)
                .padding(.horizontal, imageSize * 0.050)
            }
            .frame(width: imageSize, height: imageSize)
            .offset(y: -60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $activeSheet) { corner in
            CornerConfigSheet(corner: corner, screenID: selectedScreenID)
        }
    }
}

struct CornerButton: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    let corner: Corner
    let screenID: String?
    let action: () -> Void
    
    @State private var isHovering = false
    
    private let buttonSize: CGFloat = 42
    
    var body: some View {
        let screenConfig = configStore.cornerConfig(forScreenID: screenID)
        let cornerAction = screenConfig.action(for: corner)
        
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.black.opacity(0.4) : Color.white)
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.12), radius: 3, x: 0, y: 1)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(
                                cornerAction.isConfigured ? Color.accentColor : (colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3)),
                                style: StrokeStyle(lineWidth: 1.5, dash: cornerAction.isConfigured ? [] : [4])
                            )
                    )
                
                if cornerAction.isConfigured, let icon = cornerAction.appIcon() {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isHovering ? .accentColor : (colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5)))
                        .animation(.easeInOut(duration: 0.2), value: isHovering)
                }
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
