//
//  BaseUIViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/27/26.
//

import UIKit

class BaseUIViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        setAddTarget()
        setDelegate()
    }
    
    func setView() { }
    
    func setAddTarget() { }
    
    func setDelegate() { }
}
