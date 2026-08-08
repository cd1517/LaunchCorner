import SwiftUI

struct ScreenCornerView: View {
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
                
                // Corner buttons positioned at top and bottom outer corners of the MacBook display
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
                // Top padding 0.245 brings top buttons all the way up to top screen corners
                // Horizontal padding 0.120 moves buttons out from the screen
                .padding(.top, imageSize * 0.245)
                .padding(.bottom, imageSize * 0.160)
                .padding(.horizontal, imageSize * 0.120)
            }
            .frame(width: imageSize, height: imageSize)
            .offset(y: -40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $activeSheet) { corner in
            CornerConfigSheet(corner: corner, screenID: selectedScreenID)
        }
    }
}

struct CornerButton: View {
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
                    .fill(Color.black.opacity(0.4))
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(
                                cornerAction.isConfigured ? Color.accentColor : Color.white.opacity(0.4),
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
                        .foregroundColor(isHovering ? .accentColor : .white.opacity(0.5))
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
