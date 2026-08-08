import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject var configStore: ConfigStore
    var onBack: (() -> Void)? = nil
    
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @State private var showResetConfirmation = false
    @State private var updateStatus: String = ""
    @State private var isCheckingUpdate = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    private let githubRepo = "wenujacodes/Nook"
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Header
                    HStack {
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    
                    // General Options
                    GroupBox("General") {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Show in Menu Bar")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { configStore.config.showInMenuBar },
                                    set: { newValue in
                                        configStore.config.showInMenuBar = newValue
                                        configStore.save()
                                    }
                                ))
                                .toggleStyle(.switch)
                                .controlSize(.mini)
                                .labelsHidden()
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Enable LaunchCorner")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { configStore.config.isActive },
                                    set: { newValue in
                                        configStore.config.isActive = newValue
                                        configStore.save()
                                    }
                                ))
                                .toggleStyle(.switch)
                                .controlSize(.mini)
                                .labelsHidden()
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Launch at Login")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { launchAtLogin },
                                    set: { newValue in
                                        launchAtLogin = newValue
                                        do {
                                            if newValue {
                                                try SMAppService.mainApp.register()
                                            } else {
                                                try SMAppService.mainApp.unregister()
                                            }
                                        } catch {
                                            print("Failed to update launch at login: \(error)")
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                                .controlSize(.mini)
                                .labelsHidden()
                            }
                        }
                        .padding(8)
                    }
                    
                    // Sensitivity (Dwell Time)
                    GroupBox("Sensitivity") {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Dwell Time")
                                    Spacer()
                                    Text(configStore.config.dwellTime <= 0.01 ? "Instant (0 ms)" : String(format: "%.0f ms", configStore.config.dwellTime * 1000))
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Slider(value: $configStore.config.dwellTime, in: 0.0...0.5, step: 0.02)
                                Text("How long the cursor rests in a corner before triggering. Set to 0 ms for instant response.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                    }
                    
                    // Updates
                    GroupBox("Updates") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Automatically check for updates")
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { configStore.config.autoCheckUpdates },
                                    set: { newValue in
                                        configStore.config.autoCheckUpdates = newValue
                                        configStore.save()
                                    }
                                ))
                                .toggleStyle(.switch)
                                .controlSize(.mini)
                                .labelsHidden()
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Software Update")
                                    if !updateStatus.isEmpty {
                                        Text(updateStatus)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button("Check Now") {
                                    checkForUpdates()
                                }
                                .disabled(isCheckingUpdate)
                                .controlSize(.small)
                            }
                        }
                        .padding(8)
                    }
                    
                    // Danger Zone (Reset Section)
                    GroupBox("Danger Zone") {
                        HStack {
                            Text("Reset All Configurations")
                            Spacer()
                            Button("Reset") {
                                showResetConfirmation = true
                            }
                            .foregroundColor(.red)
                            .controlSize(.small)
                        }
                        .padding(8)
                    }
                    
                    // About Section
                    GroupBox("About") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text(appVersion)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Link("Report an Issue", destination: URL(string: "https://github.com/wenujacodes/Nook/issues")!)
                                    .foregroundColor(.accentColor)
                                Spacer()
                                Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Link("GitHub", destination: URL(string: "https://github.com/wenujacodes")!)
                                    .foregroundColor(.accentColor)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Link("X (Twitter)", destination: URL(string: "https://x.com/wenujacodes")!)
                                    .foregroundColor(.accentColor)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0x24/255.0, green: 0x23/255.0, blue: 0x21/255.0))
        .alert("Reset Everything?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset All", role: .destructive) {
                configStore.config.screenConfigs.removeAll()
                configStore.config.defaultConfig = .empty
                configStore.config.dwellTime = 0.15
                configStore.config.hitZoneSize = 15.0
                configStore.config.monitorMode = .allScreens
                configStore.config.showInMenuBar = true
                configStore.config.autoCheckUpdates = true
                configStore.save()
            }
        } message: {
            Text("This will reset all corner assignments and sensitivity settings to defaults.")
        }
    }
    
    private func checkForUpdates() {
        isCheckingUpdate = true
        updateStatus = "Checking..."
        
        guard let url = URL(string: "https://api.github.com/repos/\(githubRepo)/releases/latest") else {
            updateStatus = "Invalid repository URL"
            isCheckingUpdate = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isCheckingUpdate = false
                
                if let error = error {
                    updateStatus = "Failed: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String else {
                    updateStatus = "No releases found"
                    return
                }
                
                let latestVersion = tagName.replacingOccurrences(of: "v", with: "")
                if latestVersion.compare(appVersion, options: .numeric) == .orderedDescending {
                    updateStatus = "Update available: v\(latestVersion)"
                    if let releaseURL = json["html_url"] as? String,
                       let url = URL(string: releaseURL) {
                        NSWorkspace.shared.open(url)
                    }
                } else {
                    updateStatus = "You're up to date"
                }
            }
        }.resume()
    }
}
