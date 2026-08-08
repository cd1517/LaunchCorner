import AppKit
import SwiftUI
import Combine

@MainActor
class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private let configStore: ConfigStore
    private var cancellables = Set<AnyCancellable>()
    
    private let menu = NSMenu()
    private var toggleItem: NSMenuItem?
    
    var onOpenSettings: (() -> Void)?
    var onCheckForUpdates: (() -> Void)?
    
    init(configStore: ConfigStore) {
        self.configStore = configStore
        super.init()
        
        buildMenuOnce()
        setupObservers()
        updateMenuBarPresence()
    }
    
    private func buildMenuOnce() {
        menu.autoenablesItems = false
        
        // 1. LaunchCorner: Enabled / Disabled
        let isON = configStore.config.isActive
        let toggleTitle = isON ? "LaunchCorner: Enabled" : "LaunchCorner: Disabled"
        let toggle = NSMenuItem(title: toggleTitle, action: #selector(toggleHotCorner), keyEquivalent: "")
        toggle.target = self
        toggle.isEnabled = true
        menu.addItem(toggle)
        self.toggleItem = toggle
        
        menu.addItem(NSMenuItem.separator())
        
        // 2. Settings...
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)
        
        // 3. Check for Updates...
        let updatesItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
        updatesItem.target = self
        updatesItem.isEnabled = true
        menu.addItem(updatesItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 4. Quit LaunchCorner
        let quitItem = NSMenuItem(title: "Quit LaunchCorner", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)
    }
    
    private func setupObservers() {
        configStore.$config
            .sink { [weak self] _ in
                self?.updateMenuBarPresence()
                self?.updateToggleState()
            }
            .store(in: &cancellables)
    }
    
    func updateMenuBarPresence() {
        if configStore.config.showInMenuBar {
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                if let button = statusItem?.button {
                    button.image = NSImage(systemSymbolName: "cursorarrow.square", accessibilityDescription: "LaunchCorner")
                }
                statusItem?.menu = menu
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }
    
    private func updateToggleState() {
        let isON = configStore.config.isActive
        toggleItem?.title = isON ? "LaunchCorner: Enabled" : "LaunchCorner: Disabled"
    }
    
    @objc private func toggleHotCorner() {
        configStore.config.isActive.toggle()
        configStore.save()
        updateToggleState()
    }
    
    @objc private func openSettings() {
        onOpenSettings?()
    }
    
    @objc private func checkForUpdates() {
        onCheckForUpdates?()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
