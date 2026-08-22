//
//  HapticManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/22/26.
//

import CoreHaptics

final class HapticManager {
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    
    init() {
        configureEngine()
    }
    
    func play(_ pattern: HapticPattern) {
        guard let engine else { return }
        
        do {
            stop()

            let hapticPattern = try CHHapticPattern(
                events: pattern.events,
                parameters: []
            )
            let player = try engine.makePlayer(with: hapticPattern)

            self.player = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }

    func stop() {
        guard let player else { return }

        do {
            try player.stop(atTime: CHHapticTimeImmediate)
            self.player = nil
        } catch {
            print("Failed to stop haptic pattern: \(error)")
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
        } catch {
            print("Failed to configure haptic engine: \(error)")
        }
    }
    
    func configureHandlers(for engine: CHHapticEngine) {
        engine.resetHandler = { [weak self] in
            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart haptic engine: \(error)")
            }
        }
        
        engine.stoppedHandler = { reason in
            print("Haptic engine stopped: \(reason)")
        }
    }
}
