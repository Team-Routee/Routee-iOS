//
//  WorkoutPuaseViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

final class WorkoutPuaseViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let workoutPuaseView = WorkoutPuaseView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = workoutPuaseView
    }
}
