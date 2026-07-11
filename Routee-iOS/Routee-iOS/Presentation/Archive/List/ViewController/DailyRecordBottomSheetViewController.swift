//
//  DailyRecordBottomSheetViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class DailyRecordBottomSheetViewController: BaseUIViewController {

    // MARK: - UI Properties
    
    private let rootView = DailyRecordBottomSheet()
    private let model: CalendarDateModel
    private weak var pushNavigationController: UINavigationController?
    private let onPushNavigation: (() -> Void)?
    private var sheetHeight: CGFloat {
        DailyRecordBottomSheet.modalHeight(for: model.items.count)
    }

    // MARK: - Initializer
    
    init(
        model: CalendarDateModel,
        pushNavigationController: UINavigationController?,
        onPushNavigation: (() -> Void)?
    ) {
        self.model = model
        self.pushNavigationController = pushNavigationController
        self.onPushNavigation = onPushNavigation
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

        rootView.configure(with: model)
        rootView.onRecordChevronTap = { [weak self] _ in
            self?.navigateToSampleView()
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
                self?.sheetHeight ?? DailyRecordBottomSheet.modalHeight(for: 0)
            }
        ]
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = 24
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }

    private func navigateToSampleView() {
        let sampleViewController = SampleViewController()

        guard let pushNavigationController else {
            return
        }

        onPushNavigation?()
        dismiss(animated: false) {
            pushNavigationController.pushViewController(sampleViewController, animated: true)
        }
    }
}
