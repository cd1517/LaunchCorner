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
            
            ZStack {
                // Monitor Stand
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 120, height: 40)
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 200, height: 8)
                        .cornerRadius(4)
                }
                .padding(.top, 280) // Push stand to bottom
                
                // Monitor Screen
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    // Grid / Noise texture overlay
                    Image(systemName: "checkerboard.rectangle")
                        .resizable()
                        .opacity(0.05)
                        .blendMode(.overlay)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Wallpaper gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .padding(8)
                    
                    // Corner Buttons
                    GeometryReader { geometry in
                        let cornerSize: CGFloat = 60
                        let offset: CGFloat = 16
                        
                        CornerButton(corner: .topLeft, screenID: selectedScreenID) {
                            activeSheet = .topLeft
                        }
                        .position(x: offset + cornerSize/2, y: offset + cornerSize/2)
                        
                        CornerButton(corner: .topRight, screenID: selectedScreenID) {
                            activeSheet = .topRight
                        }
                        .position(x: geometry.size.width - offset - cornerSize/2, y: offset + cornerSize/2)
                        
                        CornerButton(corner: .bottomLeft, screenID: selectedScreenID) {
                            activeSheet = .bottomLeft
                        }
                        .position(x: offset + cornerSize/2, y: geometry.size.height - offset - cornerSize/2)
                        
                        CornerButton(corner: .bottomRight, screenID: selectedScreenID) {
                            activeSheet = .bottomRight
                        }
                        .position(x: geometry.size.width - offset - cornerSize/2, y: geometry.size.height - offset - cornerSize/2)
                    }
                }
                .frame(width: 500, height: 312) // ~16:10 aspect ratio
            }
        }
        .padding(40)
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
    
    var body: some View {
        let screenConfig = configStore.cornerConfig(forScreenID: screenID)
        let cornerAction = screenConfig.action(for: corner)
        let isTriggered = engine.lastTriggeredCorner == corner
        
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isHovering ? Color.accentColor.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(cornerAction.isConfigured ? Color.accentColor : Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: cornerAction.isConfigured ? [] : [4]))
                    )
                
                if cornerAction.isConfigured, let icon = cornerAction.appIcon() {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isHovering ? .accentColor : .white.opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovering ? 1.1 : 1.0)
        .scaleEffect(isTriggered ? 1.2 : 1.0)
        .shadow(color: (isHovering || isTriggered) ? Color.accentColor.opacity(0.5) : .clear, radius: 10)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovering)
        .animation(.easeOut(duration: 0.2), value: isTriggered)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
