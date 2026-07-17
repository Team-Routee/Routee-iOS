//
//  BaseUIViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/27/26.
//

import UIKit

class BaseUIViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureKeyboardDismissGesture()
        setView()
        setAddTarget()
        setDelegate()
    }

    private func configureKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var touchedView: UIView? = touch.view

        while let currentView = touchedView {
            if currentView is UITextField || currentView is UITextView {
                return false
            }
            touchedView = currentView.superview
        }

        return true
    }
    
    func setView() { }
    
    func setAddTarget() { }
    
    func setDelegate() { }
}
