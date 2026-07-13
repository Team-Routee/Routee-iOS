//
//  ErrorViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import UIKit

final class ErrorViewController: BaseUIViewController {
    
    // MARK: - UI Properties
    
    private let rootView: ErrorView
    
    // MARK: - Properties
    
    private let retryAction: (() -> Void)?
    
    // MARK: - Initializer
    
    init(
        errorCase: ErrorCase = .unknown,
        retryAction: (() -> Void)? = nil
    ) {
        self.rootView = ErrorView(errorCase: .unknown)
        self.retryAction = retryAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - UI Setting
    
    override func setAddTarget() {
        rootView.toHomeButton.addTarget(
            self,
            action: #selector(toHomeButtonDidTap),
            for: .touchUpInside
        )
        
        rootView.retryButton.addTarget(
            self,
            action: #selector(retryButtonDidTap),
            for: .touchUpInside
        )
    }
    
    // MARK: - Private Methods
    
    @objc
    private func toHomeButtonDidTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func retryButtonDidTap() {
        retryAction?()
    }
}
