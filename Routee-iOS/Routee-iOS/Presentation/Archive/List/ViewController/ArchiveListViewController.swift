//
//  ListViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class ArchiveListViewController: BaseUIViewController {

    // MARK: - UI Properties
    
    private let rootView = ListView()
    private let model: ListModel
    private var sheetHeight: CGFloat {
        ListView.modalHeight(for: model.items.count)
    }

    // MARK: - Initializer
    
    init(model: ListModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        rootView.backgroundColor = .grey900
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.configure(with: model)
        configureSheet()
    }

    // MARK: - Private Methods
    
    private func configureSheet() {
        view.backgroundColor = .grey900
        preferredContentSize = CGSize(width: 0, height: sheetHeight)

        guard let sheet = sheetPresentationController else { return }

        sheet.detents = [
            .custom { [weak self] _ in
                self?.sheetHeight ?? ListView.modalHeight(for: 0)
            }
        ]
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = 24
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }
}
