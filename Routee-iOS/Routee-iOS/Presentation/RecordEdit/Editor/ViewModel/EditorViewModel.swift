//
//  EditorViewModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

@MainActor
final class EditorViewModel {

    // MARK: - Properties

    private let activityRepository: ActivityRepository
    private(set) var activityEditorModel: ActivityEditorModel?

    // MARK: - Initializer

    init(activityRepository: ActivityRepository = DefaultActivityRepository()) {
        self.activityRepository = activityRepository
    }

    // MARK: - Public Methods

    func fetchActivityEditorData(activityId: Int64) async throws {
        activityEditorModel = try await activityRepository
            .getActivityRoute(activityId: activityId)
            .toEditorModel()
    }
}
