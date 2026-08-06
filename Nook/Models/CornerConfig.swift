import Foundation
import AppKit

// The 4 screen corners
enum Corner: String, Codable, CaseIterable, Identifiable {
    case topLeft, topRight, bottomLeft, bottomRight
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }
    
    var symbolName: String {
        switch self {
        case .topLeft: return "arrow.up.left"
        case .topRight: return "arrow.up.right"
        case .bottomLeft: return "arrow.down.left"
        case .bottomRight: return "arrow.down.right"
        }
    }
}

// What action to perform when a corner is triggered
enum CornerAction: Codable, Equatable {
    case none
    case launchApp(bundlePath: String, appName: String)
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .launchApp(_, let appName): return appName
        }
    }
    
    var isConfigured: Bool {
        if case .none = self { return false }
        return true
    }
    
    // Get the app icon for display, returns nil for .none
    func appIcon() -> NSImage? {
        switch self {
        case .none: return nil
        case .launchApp(let bundlePath, _):
            return NSWorkspace.shared.icon(forFile: bundlePath)
        }
    }
}

// Config for one screen's 4 corners
struct ScreenCornerConfig: Codable, Equatable {
    var corners: [String: CornerAction]
    
    static var empty: ScreenCornerConfig {
        ScreenCornerConfig(corners: [
            Corner.topLeft.rawValue: .none,
            Corner.topRight.rawValue: .none,
            Corner.bottomLeft.rawValue: .none,
            Corner.bottomRight.rawValue: .none
        ])
    }
    
    // Get/set action for a specific corner
    func action(for corner: Corner) -> CornerAction {
        return corners[corner.rawValue] ?? .none
    }
    
    mutating func setAction(_ action: CornerAction, for corner: Corner) {
        corners[corner.rawValue] = action
    }
}

// Which monitors to watch
enum MonitorMode: Codable, Equatable {
    case allScreens
    case specificScreen(String) // screen identifier
}

// Top-level app configuration
struct AppConfig: Codable, Equatable {
    var screenConfigs: [String: ScreenCornerConfig] // keyed by screen display ID
    var defaultConfig: ScreenCornerConfig // used when monitorMode is .allScreens
    var dwellTime: Double // seconds, range 0.1 - 0.5, default 0.2
    var hitZoneSize: Double // pixels, range 5 - 20, default 10
    var isActive: Bool // whether corner detection is running
    var monitorMode: MonitorMode
    
    static var `default`: AppConfig {
        AppConfig(
            screenConfigs: [:],
            defaultConfig: .empty,
            dwellTime: 0.2,
            hitZoneSize: 10.0,
            isActive: true,
            monitorMode: .allScreens
        )
    }
}
