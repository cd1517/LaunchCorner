import SwiftUI

struct ScreenCornerView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    @State private var selectedScreenID: String? = nil
    @State private var activeSheet: Corner? = nil
    
    var body: some View {
        VStack(spacing: 30) {
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
            
            // Mac screen image with corner buttons INSIDE the display area
            ZStack {
                Image("mac-screen")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 520)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .overlay(
                        GeometryReader { geometry in
                            // Calculate the actual screen/display area within the image
                            let insets = screenAreaInset(for: geometry.size)
                            let screenX = insets.leading
                            let screenY = insets.top
                            let screenW = geometry.size.width - insets.leading - insets.trailing
                            let screenH = geometry.size.height - insets.top - insets.bottom
                            
                            let cornerInset: CGFloat = 20 // distance from screen edge inward
                            
                            // Top Left — inside screen area
                            CornerButton(corner: .topLeft, screenID: selectedScreenID) {
                                activeSheet = .topLeft
                            }
                            .position(
                                x: screenX + cornerInset,
                                y: screenY + cornerInset
                            )
                            
                            // Top Right — inside screen area
                            CornerButton(corner: .topRight, screenID: selectedScreenID) {
                                activeSheet = .topRight
                            }
                            .position(
                                x: screenX + screenW - cornerInset,
                                y: screenY + cornerInset
                            )
                            
                            // Bottom Left — inside screen area
                            CornerButton(corner: .bottomLeft, screenID: selectedScreenID) {
                                activeSheet = .bottomLeft
                            }
                            .position(
                                x: screenX + cornerInset,
                                y: screenY + screenH - cornerInset
                            )
                            
                            // Bottom Right — inside screen area
                            CornerButton(corner: .bottomRight, screenID: selectedScreenID) {
                                activeSheet = .bottomRight
                            }
                            .position(
                                x: screenX + screenW - cornerInset,
                                y: screenY + screenH - cornerInset
                            )
                        }
                    )
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(item: $activeSheet) { corner in
            CornerConfigSheet(corner: corner, screenID: selectedScreenID)
        }
    }
    
    /// Insets from the image edges to the actual screen/display area
    /// within the mac-screen.png. These map the bezel + chin of the laptop image.
    private func screenAreaInset(for imageSize: CGSize) -> (top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat) {
        let top = imageSize.height * 0.035
        let leading = imageSize.width * 0.115
        let bottom = imageSize.height * 0.145
        let trailing = imageSize.width * 0.115
        return (top, leading, bottom, trailing)
    }
}

struct CornerButton: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var engine: CornerDetectionEngine
    
    let corner: Corner
    let screenID: String?
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        let screenConfig = configStore.cornerConfig(forScreenID: screenID)
        let cornerAction = screenConfig.action(for: corner)
        
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
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
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
