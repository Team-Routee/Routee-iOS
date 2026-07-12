//
//  WorkoutTimeLineViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import UIKit

final class WorkoutTimeLineViewController: BaseUIViewController {
    let workoutTimelineView = WorkoutTimeLineView()
    
    override func loadView() {
        view = workoutTimelineView
    }
}
