//
//  AnalyticsEvent.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/3/26.
//

import Foundation

enum AnalyticsEvent: String {
    case signUpCompleted = "sign_up_completed"
    case onboardingCompleted = "onboarding_completed"

    case workoutStarted = "workout_started"
    case workoutRecordingEnded = "workout_recording_ended"
    case workoutCompleted = "workout_completed"
    case workoutCompleteFailed = "workout_complete_failed"

    case recapEditorOpened = "recap_editor_opened"
    case recapEdited = "recap_edited"
    case recapCompleted = "recap_completed"
    case recapAbandoned = "recap_abandoned"
    case recapSaved = "recap_saved"
    case recapShared = "recap_shared"
}
