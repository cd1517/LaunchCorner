import SwiftUI

struct ScreenCornerView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var selectedScreenID: String? = nil
    @State private var activeSheet: Corner? = nil
    
    // Fixed image size so buttons never drift
    private let imageWidth: CGFloat = 480
    private let imageHeight: CGFloat = 320
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            // Mac screen image at a fixed size with corner buttons inside the display
            ZStack {
                Image("mac-screen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageWidth, height: imageHeight)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Corner buttons at fixed pixel positions inside the screen area
                // These offsets are tuned to place buttons inside the display bezel
                let screenLeft: CGFloat = imageWidth * 0.115
                let screenRight: CGFloat = imageWidth * (1.0 - 0.115)
                let screenTop: CGFloat = imageHeight * 0.04
                let screenBottom: CGFloat = imageHeight * (1.0 - 0.16)
                let inset: CGFloat = 24  // how far inward from screen edge
                
                CornerButton(corner: .topLeft, screenID: selectedScreenID) {
                    activeSheet = .topLeft
                }
                .position(x: screenLeft + inset, y: screenTop + inset)
                
                CornerButton(corner: .topRight, screenID: selectedScreenID) {
                    activeSheet = .topRight
                }
                .position(x: screenRight - inset, y: screenTop + inset)
                
                CornerButton(corner: .bottomLeft, screenID: selectedScreenID) {
                    activeSheet = .bottomLeft
                }
                .position(x: screenLeft + inset, y: screenBottom - inset)
                
                CornerButton(corner: .bottomRight, screenID: selectedScreenID) {
                    activeSheet = .bottomRight
                }
                .position(x: screenRight - inset, y: screenBottom - inset)
            }
            .frame(width: imageWidth, height: imageHeight)
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
    
    private let buttonSize: CGFloat = 44
    
    var body: some View {
        let screenConfig = configStore.cornerConfig(forScreenID: screenID)
        let cornerAction = screenConfig.action(for: corner)
        
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: buttonSize, height: buttonSize)
                    .overlay(
                        Circle()
                            .stroke(
                                cornerAction.isConfigured ? Color.accentColor : Color.white.opacity(0.3),
                                style: StrokeStyle(lineWidth: 1.5, dash: cornerAction.isConfigured ? [] : [4])
                            )
                    )
                
                if cornerAction.isConfigured, let icon = cornerAction.appIcon() {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isHovering ? .accentColor : .white.opacity(0.4))
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
