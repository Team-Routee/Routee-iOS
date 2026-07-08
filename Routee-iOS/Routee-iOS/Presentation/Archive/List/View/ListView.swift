//
//  ArchiveListView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class ArchiveListView: BaseUIView {

    private enum Metric {
        static let compactHeight: CGFloat = 247
        static let expandedHeight: CGFloat = 344
        static let maxVisibleCount = 3
    }

    private let handleView = UIView()
    private let dateLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    override func setStyle() {
        backgroundColor = .grey_900
        layer.cornerRadius = .r24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true

        handleView.do {
            $0.backgroundColor = .static_white
            $0.layer.cornerRadius = 2.5
            $0.alpha = 0.8
        }

        dateLabel.do {
            $0.textColor = .static_white
            $0.font = .label_sb_14
            $0.textAlignment = .left
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = false
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 12
        }
    }

    override func setUI() {
        addSubviews(handleView, dateLabel, scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
    }

    override func setLayout() {
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(5)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        }
    }

    func configure(with model: ListModel) {
        dateLabel.text = model.dateText

        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        model.items.forEach { item in
            let itemView = ListItemView()
            itemView.configure(with: item)
            stackView.addArrangedSubview(itemView)
        }

        let shouldScroll = model.items.count > Metric.maxVisibleCount
        scrollView.isScrollEnabled = shouldScroll
        scrollView.alwaysBounceVertical = shouldScroll
    }

    static func modalHeight(for itemCount: Int) -> CGFloat {
        itemCount <= 2 ? Metric.compactHeight : Metric.expandedHeight
    }
}
