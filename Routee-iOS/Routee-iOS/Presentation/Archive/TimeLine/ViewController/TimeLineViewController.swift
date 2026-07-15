//
//  TimeLineViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/12/26.
//

import UIKit

final class TimeLineViewController: BaseUIViewController {

    // MARK: - UI Properties

    private let rootView: TimeLineView

    // MARK: - Initializer

    init(record: ActivityListModel? = nil) {
        self.rootView = TimeLineView(record: record)
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

    override func setView() {
        rootView.backButtonAction = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
