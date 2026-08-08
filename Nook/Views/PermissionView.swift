import SwiftUI

struct PermissionView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // App icon
            Image(systemName: "macwindow.on.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.accentColor)
                .padding(.bottom, 20)
            
            // Title
            Text("Welcome to Nook")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.bottom, 8)
            
            // Subtitle
            Text("A hot corner utility for macOS")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.bottom, 36)
            
            // Feature list — Kaset style
            VStack(alignment: .leading, spacing: 24) {
                featureRow(
                    icon: "cursorarrow.motionlines",
                    title: "Corner Detection",
                    description: "Launch apps by moving your cursor to screen corners"
                )
                
                featureRow(
                    icon: "display.2",
                    title: "Multi-Monitor",
                    description: "Works across all your connected displays"
                )
                
                featureRow(
                    icon: "gearshape",
                    title: "Customizable",
                    description: "Adjust sensitivity, dwell time, and hit zone size"
                )
                
                featureRow(
                    icon: "lock.open",
                    title: "Accessibility Access",
                    description: "Required to detect cursor position globally"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Action button — solid accent color, compact
            Button(action: {
                permissionManager.openAccessibilitySettings()
            }) {
                Text("Open System Settings")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 6)
            
            // Helper text
            Text("Grant Accessibility access to get started")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0x24/255.0, green: 0x23/255.0, blue: 0x21/255.0))
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
