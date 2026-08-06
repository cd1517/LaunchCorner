import Foundation
import AppKit

// Simple utility to execute corner actions
class ActionExecutor {
    static func execute(_ action: CornerAction) {
        switch action {
        case .none:
            break
        case .launchApp(let bundlePath, _):
            launchApp(atPath: bundlePath)
        }
    }
    
    static func launchApp(atPath path: String) {
        let url = URL(fileURLWithPath: path)
        let configuration = NSWorkspace.OpenConfiguration()
        
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { (app, error) in
            if let error = error {
                print("Failed to launch app at \(path): \(error.localizedDescription)")
            }
        }
    }
}
