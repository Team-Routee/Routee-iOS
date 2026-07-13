//
//  WorkoutTimeLineViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import UIKit

final class WorkoutTimeLineViewController: BaseUIViewController {
    private let workoutTimelineView = WorkoutTimeLineView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = workoutTimelineView
    
        workoutTimelineView.backButtonAction = {
            self.navigationController?.popToRootViewController(animated: true)
        }

        workoutTimelineView.completeButtonAction = {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        workoutTimelineView.goToEditButton.addTarget(self, action: #selector(didTapGoToEditButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapGoToEditButton() {
        self.navigationController?.pushViewController(EditorViewController(), animated: true)
    }
}
