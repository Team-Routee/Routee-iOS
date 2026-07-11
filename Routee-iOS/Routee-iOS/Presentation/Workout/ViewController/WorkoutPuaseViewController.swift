//
//  WorkoutPauseViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

final class WorkoutPauseViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let workoutPauseView = WorkoutPauseView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = workoutPauseView
    }
}
