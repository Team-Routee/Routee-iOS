//
//  RecordEditResourceViewModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

@MainActor
final class RecordEditResourceViewModel {

    // MARK: - Properties

    private let activityRepository: ActivityRepository
    private(set) var recordEditResourceModel: RecordEditResourceModel?

    // MARK: - Initializer

    init(activityRepository: ActivityRepository = RecordEditActivityRepository.make()) {
        self.activityRepository = activityRepository
    }

    // MARK: - Public Methods

    func fetchRecordEditResourceData(activityId: Int64) async throws {
        recordEditResourceModel = try await activityRepository.getRecordEditResource(activityId: activityId)
    }
}
