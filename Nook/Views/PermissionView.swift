import SwiftUI

struct PermissionView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 10)
            }
            .scaleEffect(isAnimating ? 1.05 : 0.95)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 12) {
                Text("Nook needs Accessibility Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("To detect when your cursor reaches screen corners, Nook needs Accessibility permission.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                stepRow(number: 1, text: "Click 'Open System Settings' below", icon: "gearshape.fill")
                stepRow(number: 2, text: "Find Nook in the list", icon: "magnifyingglass")
                stepRow(number: 3, text: "Toggle it on", icon: "switch.2")
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(16)
            
            VStack(spacing: 16) {
                Button(action: {
                    permissionManager.openAccessibilitySettings()
                }) {
                    Text("Open System Settings")
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    permissionManager.requestPermission()
                }) {
                    Text("Check Again")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            isAnimating = true
        }
    }
    
    private func stepRow(number: Int, text: String, icon: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}
