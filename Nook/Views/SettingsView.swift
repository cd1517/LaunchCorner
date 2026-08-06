import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var configStore: ConfigStore
    
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.thinMaterial)
            
            ScrollView {
                VStack(spacing: 24) {
                    // General
                    GroupBox("General") {
                        VStack(alignment: .leading, spacing: 16) {
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
                                .labelsHidden()
                            }
                        }
                        .padding(8)
                    }
                    
                    // Sensitivity
                    GroupBox("Sensitivity") {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Dwell Time")
                                    Spacer()
                                    Text(String(format: "%.0f ms", configStore.config.dwellTime * 1000))
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Slider(value: $configStore.config.dwellTime, in: 0.1...0.5, step: 0.05)
                                Text("How long the cursor must rest in a corner before triggering.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Hit Zone Size")
                                    Spacer()
                                    Text(String(format: "%.0f px", configStore.config.hitZoneSize))
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                Slider(value: $configStore.config.hitZoneSize, in: 5...20, step: 1)
                                Text("The size of the sensitive area in each corner.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                    }
                    
                    // Danger Zone
                    GroupBox("Danger Zone") {
                        HStack {
                            Text("Reset All Configurations")
                            Spacer()
                            Button("Reset") {
                                configStore.config.screenConfigs.removeAll()
                                configStore.config.defaultConfig = .empty
                                configStore.save()
                            }
                            .foregroundColor(.red)
                        }
                        .padding(8)
                    }
                }
                .padding()
            }
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
