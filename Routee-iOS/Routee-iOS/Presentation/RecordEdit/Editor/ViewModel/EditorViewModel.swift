//
//  EditorViewModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

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
        let responseDTO = try await activityRepository.getActivityRoute(activityId: activityId)
        activityEditorModel = responseDTO.toEditorModel()
    }
}
