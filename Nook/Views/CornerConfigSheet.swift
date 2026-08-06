import SwiftUI
import UniformTypeIdentifiers

struct CornerConfigSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var configStore: ConfigStore
    
    let corner: Corner
    let screenID: String?
    
    @State private var selectedActionType: ActionType = .none
    @State private var selectedAppPath: String = ""
    @State private var selectedAppName: String = ""
    @State private var selectedAppIcon: NSImage? = nil
    
    enum ActionType: String, CaseIterable, Identifiable {
        case none = "None"
        case launchApp = "Launch App"
        var id: String { rawValue }
    }
    
    init(corner: Corner, screenID: String? = nil) {
        self.corner = corner
        self.screenID = screenID
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Image(systemName: corner.symbolName)
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
                    )
                Text("\(corner.displayName) Configuration")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Picker
            Picker("Action", selection: $selectedActionType) {
                ForEach(ActionType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            // App Selection
            if selectedActionType == .launchApp {
                VStack(spacing: 16) {
                    if !selectedAppName.isEmpty {
                        HStack(spacing: 16) {
                            if let icon = selectedAppIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                                    .overlay(Image(systemName: "questionmark.app.dashed").foregroundColor(.secondary))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(selectedAppName)
                                    .font(.headline)
                                Text(selectedAppPath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    Button(action: selectApp) {
                        Text(selectedAppName.isEmpty ? "Choose Application..." : "Change Application...")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(.accentColor)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Spacer().frame(height: 100)
            }
            
            Spacer()
            
            // Footer
            HStack {
                Button("Clear") {
                    selectedActionType = .none
                    selectedAppPath = ""
                    selectedAppName = ""
                    selectedAppIcon = nil
                }
                .foregroundColor(.red)
                .disabled(selectedActionType == .none)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    saveAction()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(selectedActionType == .launchApp && selectedAppPath.isEmpty)
            }
        }
        .padding(30)
        .frame(width: 450, height: 350)
        .onAppear {
            loadCurrentConfig()
        }
    }
    
    private func loadCurrentConfig() {
        let config = configStore.cornerConfig(forScreenID: screenID)
        let action = config.action(for: corner)
        
        switch action {
        case .none:
            selectedActionType = .none
        case .launchApp(let path, let name):
            selectedActionType = .launchApp
            selectedAppPath = path
            selectedAppName = name
            selectedAppIcon = action.appIcon()
        }
    }
    
    private func saveAction() {
        let newAction: CornerAction
        switch selectedActionType {
        case .none:
            newAction = .none
        case .launchApp:
            if !selectedAppPath.isEmpty {
                newAction = .launchApp(bundlePath: selectedAppPath, appName: selectedAppName)
            } else {
                newAction = .none
            }
        }
        configStore.setCornerAction(newAction, for: corner, screenID: screenID)
        configStore.save()
    }
    
    private func selectApp() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.applicationBundle]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.treatsFilePackagesAsDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            selectedAppPath = url.path
            selectedAppName = url.deletingPathExtension().lastPathComponent
            
            let workspace = NSWorkspace.shared
            selectedAppIcon = workspace.icon(forFile: url.path)
        }
    }
}
