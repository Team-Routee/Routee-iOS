//
//  SampleViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/22/26.
//

import UIKit

class SampleViewController: BaseUIViewController {
    private let rootView = SampleView()
    
    override func loadView() {
        view = rootView
    }
}
