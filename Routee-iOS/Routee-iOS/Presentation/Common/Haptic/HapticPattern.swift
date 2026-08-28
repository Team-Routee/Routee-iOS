//
//  HapticPattern.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/22/26.
//

import CoreHaptics

enum HapticPattern {
    case workoutFinished
    
    var events: [CHHapticEvent] {
        switch self {
        case .workoutFinished:
            return workoutFinishedEvents
        }
    }
}

private extension HapticPattern {
    var workoutFinishedEvents: [CHHapticEvent] {
        [
            makeContinuousEvent(
                relativeTime: 0.4,
                duration: 0.3,
                intensity: 0.3,
                sharpness: 0.4
            ),
            makeContinuousEvent(
                relativeTime: 1.0,
                duration: 0.5,
                intensity: 0.25,
                sharpness: 0.3
            )
        ]
    }
}

private extension HapticPattern {
    func makeContinuousEvent(
        relativeTime: TimeInterval,
        duration: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: intensity
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: sharpness
                )
            ],
            relativeTime: relativeTime,
            duration: duration
        )
    }
}
