//
//  WorkoutPuaseViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

final class WorkoutPuaseViewController: BaseUIViewController {
    private let workoutPuaseView = WorkoutPuaseView()
    
    override func loadView() {
        view = workoutPuaseView
    }
}
