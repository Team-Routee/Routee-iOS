//
//  WorkoutPhotoLocationViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/12/26.
//

import UIKit

final class WorkoutPhotoLocationViewController: BaseUIViewController {
    
    private let rootView: WorkoutPhotoLocationView
    
    init(image: UIImage) {
        rootView = WorkoutPhotoLocationView(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        rootView.completeButton.addTarget(
            self,
            action: #selector(didTapCompleteButton),
            for: .touchUpInside
        )
        
        rootView.locationTextField.addTarget(
            self,
            action: #selector(locationTextDidChange(_:)),
            for: .editingChanged
        )
        
        rootView.locationTextField.addTarget(
            self,
            action: #selector(locationTextFieldDidSubmit),
            for: .editingDidEndOnExit
        )
    }
    
    @objc
    private func didTapCompleteButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func locationTextDidChange(_ textField: UITextField) {
        guard textField.markedTextRange == nil else { return }
        
        let currentText = textField.text ?? ""
        let limitedText = String(currentText.prefix(16))
        
        if currentText != limitedText {
            textField.text = limitedText
        }
        
        rootView.updateTextLength(limitedText.count)
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let screenFrame = notification.userInfo?[frameKey] as? CGRect else { return }
        
        let keyboardFrame = view.convert(screenFrame, from: nil)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.rootView.moveContent(toKeyboardTop: keyboardFrame.minY)
        }
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.rootView.resetContentPosition()
        }
    }
    
    @objc
    private func locationTextFieldDidSubmit() {
        rootView.locationTextField.resignFirstResponder()
    }
}
