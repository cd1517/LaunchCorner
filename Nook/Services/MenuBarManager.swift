import AppKit
import SwiftUI
import Combine

@MainActor
class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private let configStore: ConfigStore
    private var cancellables = Set<AnyCancellable>()
    
    var onOpenSettings: (() -> Void)?
    var onCheckForUpdates: (() -> Void)?
    
    init(configStore: ConfigStore) {
        self.configStore = configStore
        super.init()
        
        setupObservers()
        updateMenuBarPresence()
    }
    
    private func setupObservers() {
        configStore.$config
            .sink { [weak self] _ in
                self?.updateMenuBarPresence()
                self?.updateMenu()
            }
            .store(in: &cancellables)
    }
    
    func updateMenuBarPresence() {
        if configStore.config.showInMenuBar {
            if statusItem == nil {
                statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
                if let button = statusItem?.button {
                    button.image = NSImage(systemSymbolName: "cursorarrow.square", accessibilityDescription: "Nook")
                }
                updateMenu()
            }
        } else {
            if let item = statusItem {
                NSStatusBar.system.removeStatusItem(item)
                statusItem = nil
            }
        }
    }
    
    func updateMenu() {
        guard let statusItem = statusItem else { return }
        
        let menu = NSMenu()
        
        // 1. Hot Corner: ON / OFF
        let isON = configStore.config.isActive
        let toggleTitle = isON ? "Hot Corner: ON" : "Hot Corner: OFF"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleHotCorner), keyEquivalent: "")
        toggleItem.target = self
        if isON {
            toggleItem.state = .on
        }
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 2. Settings...
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // 3. Check for Updates...
        let updatesItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
        updatesItem.target = self
        menu.addItem(updatesItem)
        
        // 4. About Nook
        let aboutItem = NSMenuItem(title: "About Nook", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 5. Quit Nook
        let quitItem = NSMenuItem(title: "Quit Nook", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func toggleHotCorner() {
        configStore.config.isActive.toggle()
        configStore.save()
        updateMenu()
    }
    
    @objc private func openSettings() {
        onOpenSettings?()
    }
    
    @objc private func checkForUpdates() {
        onCheckForUpdates?()
    }
    
    @objc private func openAbout() {
        onOpenSettings?()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
