import Foundation
import SwiftUI
import Combine

// Observable store that persists AppConfig to UserDefaults
@MainActor
class ConfigStore: ObservableObject {
    let configDidChange = PassthroughSubject<AppConfig, Never>()
    
    @Published var config: AppConfig {
        didSet {
            save()
            configDidChange.send(config)
        }
    }
    
    private let userDefaultsKey = "LaunchCornerAppConfig"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(AppConfig.self, from: data) {
            self.config = decoded
        } else if let oldData = UserDefaults.standard.data(forKey: "NookAppConfig"),
                  let decoded = try? JSONDecoder().decode(AppConfig.self, from: oldData) {
            self.config = decoded
        } else {
            self.config = .default
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // Convenience accessors
    func cornerConfig(forScreenID screenID: String?) -> ScreenCornerConfig {
        guard let screenID = screenID else { return config.defaultConfig }
        switch config.monitorMode {
        case .allScreens:
            return config.defaultConfig
        case .specificScreen(let targetScreenID):
            if screenID == targetScreenID {
                return config.screenConfigs[screenID] ?? config.defaultConfig
            } else {
                return .empty
            }
        }
    }
    
    func setCornerAction(_ action: CornerAction, for corner: Corner, screenID: String?) {
        if let screenID = screenID, case .specificScreen(let targetID) = config.monitorMode, screenID == targetID {
            var screenConfig = config.screenConfigs[screenID] ?? config.defaultConfig
            screenConfig.setAction(action, for: corner)
            config.screenConfigs[screenID] = screenConfig
        } else {
            config.defaultConfig.setAction(action, for: corner)
        }
    }
}
