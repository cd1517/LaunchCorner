import Foundation
import AppKit
import Sparkle

@MainActor
class UpdateManager: NSObject, ObservableObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    private var updater: SPUUpdater?
    private var userDriver: SPUStandardUserDriver?
    
    override init() {
        super.init()
        
        let hostBundle = Bundle.main
        let driver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: self)
        self.userDriver = driver
        
        self.updater = SPUUpdater(
            hostBundle: hostBundle,
            applicationBundle: hostBundle,
            userDriver: driver,
            delegate: self
        )
        
        do {
            try self.updater?.start()
        } catch {
            print("Sparkle initialization error: \(error.localizedDescription)")
        }
    }
    
    func checkForUpdates() {
        if let updater = updater, updater.canCheckForUpdates {
            updater.checkForUpdates()
        } else {
            showUpToDateAlert()
        }
    }
    
    var canCheckForUpdates: Bool {
        updater?.canCheckForUpdates ?? false
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        showUpToDateAlert()
    }
    
    private func showUpToDateAlert() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let alert = NSAlert()
        alert.messageText = "You're Up to Date"
        alert.informativeText = "LaunchCorner \(version) is currently the newest version available."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
