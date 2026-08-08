import SwiftUI

struct ScreenCornerView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var selectedScreenID: String? = nil
    @State private var activeSheet: Corner? = nil
    
    // Image rendered at this fixed size — fills the window nicely
    private let imageSize: CGFloat = 500
    
    // Display area percentages measured from the 1500x1500 source image
    // Buttons sit right at the display edges (no inset)
    private let displayTopPct:    CGFloat = 0.265
    private let displayBottomPct: CGFloat = 0.790
    private let displayLeftPct:   CGFloat = 0.140
    private let displayRightPct:  CGFloat = 0.860
    
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
            
            // Mac image with corner buttons at the exact display edges
            ZStack {
                Image("mac-screen")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                
                // Buttons positioned at the very edges of the display area
                let dLeft   = imageSize * displayLeftPct
                let dRight  = imageSize * displayRightPct
                let dTop    = imageSize * displayTopPct
                let dBottom = imageSize * displayBottomPct
                
                CornerButton(corner: .topLeft, screenID: selectedScreenID) {
                    activeSheet = .topLeft
                }
                .position(x: dLeft, y: dTop)
                
                CornerButton(corner: .topRight, screenID: selectedScreenID) {
                    activeSheet = .topRight
                }
                .position(x: dRight, y: dTop)
                
                CornerButton(corner: .bottomLeft, screenID: selectedScreenID) {
                    activeSheet = .bottomLeft
                }
                .position(x: dLeft, y: dBottom)
                
                CornerButton(corner: .bottomRight, screenID: selectedScreenID) {
                    activeSheet = .bottomRight
                }
                .position(x: dRight, y: dBottom)
            }
            .frame(width: imageSize, height: imageSize)
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
    
    private let buttonSize: CGFloat = 38
    
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
                        .frame(width: 22, height: 22)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .medium))
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
