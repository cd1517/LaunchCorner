import Foundation
import AppKit
import Combine

extension NSScreen {
    var displayID: String? {
        if let number = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
            return String(number)
        }
        return nil
    }
}

@MainActor
class CornerDetectionEngine: ObservableObject {
    @Published var isActive: Bool = false
    @Published var lastTriggeredCorner: Corner? = nil
    
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var dwellTimer: DispatchSourceTimer?
    private var currentCorner: (corner: Corner, screenID: String)? = nil
    private var hasTriggeredForCurrentEntry: Bool = false
    private var cooldownActive: Bool = false
    
    private let configStore: ConfigStore
    private var cancellables = Set<AnyCancellable>()
    
    init(configStore: ConfigStore) {
        self.configStore = configStore
        
        configStore.$config
            .map { $0.isActive }
            .removeDuplicates()
            .sink { [weak self] isActive in
                if isActive {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            .store(in: &cancellables)
    }
    
    func start() {
        guard !isActive else { return }
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMoved(event: event)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMoved(event: event)
            return event
        }
        
        isActive = true
    }
    
    func stop() {
        guard isActive else { return }
        
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        
        cancelDwellTimer()
        isActive = false
    }
    
    private func handleMouseMoved(event: NSEvent) {
        let location = NSEvent.mouseLocation
        
        if let detected = detectCorner(at: location) {
            if currentCorner?.corner != detected.corner || currentCorner?.screenID != detected.screenID {
                // Entered a brand new corner
                currentCorner = detected
                hasTriggeredForCurrentEntry = false
                if !cooldownActive {
                    startDwellTimer(for: detected.corner, screenID: detected.screenID)
                }
            } else {
                // Mouse is still inside the SAME corner
                // Only start dwell timer if it hasn't triggered for this entry yet and no cooldown
                if !hasTriggeredForCurrentEntry && !cooldownActive && dwellTimer == nil {
                    startDwellTimer(for: detected.corner, screenID: detected.screenID)
                }
            }
        } else {
            // Mouse exited corner hit zone completely
            if currentCorner != nil {
                currentCorner = nil
                hasTriggeredForCurrentEntry = false
                cancelDwellTimer()
            }
        }
    }
    
    private func detectCorner(at point: NSPoint) -> (corner: Corner, screenID: String)? {
        let hitZone = configStore.config.hitZoneSize
        
        for screen in NSScreen.screens {
            guard let screenID = screen.displayID else { continue }
            
            switch configStore.config.monitorMode {
            case .allScreens:
                break
            case .specificScreen(let targetID):
                if screenID != targetID { continue }
            }
            
            let frame = screen.frame
            
            if point.x <= frame.minX + hitZone && point.y >= frame.maxY - hitZone {
                return (.topLeft, screenID)
            } else if point.x >= frame.maxX - hitZone && point.y >= frame.maxY - hitZone {
                return (.topRight, screenID)
            } else if point.x <= frame.minX + hitZone && point.y <= frame.minY + hitZone {
                return (.bottomLeft, screenID)
            } else if point.x >= frame.maxX - hitZone && point.y <= frame.minY + hitZone {
                return (.bottomRight, screenID)
            }
        }
        return nil
    }
    
    private func startDwellTimer(for corner: Corner, screenID: String) {
        cancelDwellTimer()
        
        let config = configStore.cornerConfig(forScreenID: screenID)
        let action = config.action(for: corner)
        
        guard action.isConfigured else { return }
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        let dwellTime = configStore.config.dwellTime
        
        timer.schedule(deadline: .now() + dwellTime)
        timer.setEventHandler { [weak self] in
            self?.triggerAction(for: corner, screenID: screenID)
        }
        timer.resume()
        self.dwellTimer = timer
    }
    
    private func cancelDwellTimer() {
        dwellTimer?.cancel()
        dwellTimer = nil
    }
    
    private func triggerAction(for corner: Corner, screenID: String) {
        cancelDwellTimer()
        hasTriggeredForCurrentEntry = true // Mark as triggered for this entry into the corner
        
        let config = configStore.cornerConfig(forScreenID: screenID)
        let action = config.action(for: corner)
        
        guard action.isConfigured else { return }
        
        ActionExecutor.execute(action)
        lastTriggeredCorner = corner
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if self?.lastTriggeredCorner == corner {
                self?.lastTriggeredCorner = nil
            }
        }
        
        startCooldown()
    }
    
    private func startCooldown() {
        cooldownActive = true
        // 1-second cooldown after triggering before another corner can trigger
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.cooldownActive = false
        }
    }
}
