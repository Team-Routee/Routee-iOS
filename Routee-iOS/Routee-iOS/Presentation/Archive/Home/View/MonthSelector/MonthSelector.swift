//
//  MonthSelector
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class MonthSelector: BaseUIView {

    // MARK: - Properties

    var onPreviousTap: (() -> Void)?
    var onNextTap: (() -> Void)?

    // MARK: - UI Properties

    private let stackView = UIStackView()
    private let previousButton = UIButton(type: .custom)
    private let monthLabel = UILabel()
    private let nextButton = UIButton(type: .custom)

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAddTarget()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    override func setStyle() {
        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 24
        }

        previousButton.do {
            $0.setImage(.icChevronLeftSmWhite, for: .normal)
        }

        monthLabel.do {
            $0.textColor = .static_white
            $0.font = .title_sb_20
            $0.textAlignment = .center
        }

        nextButton.do {
            $0.setImage(.icChevronLeftSmWhite.withHorizontallyFlippedOrientation(), for: .normal)
        }
    }

    override func setUI() {
        addSubview(stackView)
        stackView.addArrangedSubviews(previousButton, monthLabel, nextButton)
    }

    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        previousButton.snp.makeConstraints {
            $0.size.equalTo(32)
        }

        nextButton.snp.makeConstraints {
            $0.size.equalTo(32)
        }

        monthLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(120)
        }
    }

    func configure(title: String) {
        monthLabel.text = title
    }

    private func setAddTarget() {
        previousButton.addTarget(
            self,
            action: #selector(previousButtonDidTap),
            for: .touchUpInside
        )

        nextButton.addTarget(
            self,
            action: #selector(nextButtonDidTap),
            for: .touchUpInside
        )
    }

    @objc
    private func previousButtonDidTap() {
        onPreviousTap?()
    }

    @objc
    private func nextButtonDidTap() {
        onNextTap?()
    }
}
