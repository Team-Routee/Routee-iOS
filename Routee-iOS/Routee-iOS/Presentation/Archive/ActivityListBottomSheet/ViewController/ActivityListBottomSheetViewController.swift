//
//  ActivityListBottomSheetViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

final class ActivityListBottomSheetViewController: BaseUIViewController {

    // MARK: - UI Properties
    
    private let rootView = ActivityListBottomSheet()
    private let viewModel: ActivityListViewModel
    private var sheetHeight: CGFloat {
        viewModel.isCompactHeight ? 247 : 344
    }

    // MARK: - Initializer
    
    init(model: ActivityListDateModel) {
        self.viewModel = ActivityListViewModel(model: model)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.configure(with: viewModel)
        rootView.onRecordChevronTap = { [weak self] index in
            guard let self,
                  let record = viewModel.record(at: index) else { return }

            navigateToTimeLineView(record: record)
        }
        configureSheet()
    }

    // MARK: - Private Methods
    
    private func configureSheet() {
        view.backgroundColor = .grey900
        preferredContentSize = CGSize(width: 0, height: sheetHeight)

        guard let sheet = sheetPresentationController else { return }

        sheet.detents = [
            .custom { [weak self] _ in
                self?.sheetHeight ?? 247
            }
        ]
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = 24
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }

    private func navigateToTimeLineView(record: ActivityListModel) {
        let timeLineViewController = TimeLineViewController(record: record)
        timeLineViewController.modalPresentationStyle = .fullScreen

        present(timeLineViewController, animated: true)
    }
}
