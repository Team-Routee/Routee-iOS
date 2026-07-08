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

    private let rootView = ListView()
    private let model: ListModel

    init(model: ListModel = ArchiveListDummyData.defaultModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(dateText: String, count: Int) {
        self.init(model: ArchiveListDummyData.makeModel(dateText: dateText, count: count))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.configure(with: model)
        configureSheet()
    }

    private func configureSheet() {
        preferredContentSize = CGSize(width: 0, height: ListView.modalHeight(for: model.items.count))

        guard let sheet = sheetPresentationController else { return }

        let targetHeight = ListView.modalHeight(for: model.items.count)
        sheet.detents = [
            .custom { _ in targetHeight }
        ]
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = 24
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }
}
