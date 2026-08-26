//
//  HapticManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/22/26.
//

import CoreHaptics

@MainActor
final class HapticManager {
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    private var isEngineRunning = false
    
    init() {
        configureEngine()
    }
    
    func play(_ pattern: HapticPattern) {
        guard let engine else { return }
        
        do {
            stop()

            if !isEngineRunning {
                try engine.start()
                isEngineRunning = true
            }

            let hapticPattern = try CHHapticPattern(
                events: pattern.events,
                parameters: []
            )
            let player = try engine.makePlayer(with: hapticPattern)

            self.player = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            RouteeLogger.error(error)
        }
    }

    func stop() {
        guard let player else { return }

        do {
            try player.stop(atTime: CHHapticTimeImmediate)
            self.player = nil
        } catch {
            RouteeLogger.error(error)
        }
    }
}

private extension HapticManager {
    func configureEngine() {
        guard CHHapticEngine
            .capabilitiesForHardware()
            .supportsHaptics else {
            return
        }
        
        do {
            let engine = try CHHapticEngine()
            
            configureHandlers(for: engine)
            
            try engine.start()

            self.engine = engine
            isEngineRunning = true
        } catch {
            RouteeLogger.error(error)
        }
    }
    
    func configureHandlers(for engine: CHHapticEngine) {
        engine.resetHandler = { [weak self] in
            Task { @MainActor [weak self] in
                self?.handleEngineReset()
            }
        }
        
        engine.stoppedHandler = { [weak self] reason in
            Task { @MainActor [weak self] in
                self?.handleEngineStopped(reason: reason)
            }
        }
    }

    func handleEngineReset() {
        player = nil
        isEngineRunning = false

        guard let engine else { return }

        do {
            try engine.start()
            isEngineRunning = true
        } catch {
            RouteeLogger.error(error)
        }
    }

    func handleEngineStopped(reason: CHHapticEngine.StoppedReason) {
        player = nil
        isEngineRunning = false
        RouteeLogger.debug("Haptic engine stopped: \(reason.rawValue)")
    }
}
