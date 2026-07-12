//
//  TimeLineViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/12/26.
//

import UIKit

final class TimeLineViewController: BaseUIViewController {

    // MARK: - UI Properties

    private let rootView = TimeLineView()

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    // MARK: - UI Setting

    override func setView() {
        rootView.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
