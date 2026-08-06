import Foundation
import AppKit
import ApplicationServices
import Combine

@MainActor
class PermissionManager: ObservableObject {
    @Published var isAccessibilityGranted: Bool = false
    
    private var checkTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkPermission(prompt: false)
        
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkPermission(prompt: false)
            }
            .store(in: &cancellables)
    }
    
    func requestPermission() {
        checkPermission(prompt: true)
    }
    
    func openAccessibilitySettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func startMonitoringPermission() {
        stopMonitoringPermission()
        checkTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPermission(prompt: false)
                if self?.isAccessibilityGranted == true {
                    self?.stopMonitoringPermission()
                }
            }
        }
    }
    
    func stopMonitoringPermission() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
    
    @discardableResult
    private func checkPermission(prompt: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt]
        let isGranted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        self.isAccessibilityGranted = isGranted
        return isGranted
    }
}
