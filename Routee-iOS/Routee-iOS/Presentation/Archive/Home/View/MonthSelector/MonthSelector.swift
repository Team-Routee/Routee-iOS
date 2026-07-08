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
            $0.spacing = 6
        }

        previousButton.do {
            configureButton($0, normalImage: .icChevronLeftSmWhite, disabledImage: .icChevronLeftSmGrey)
        }

        monthLabel.do {
            $0.textColor = .static_white
            $0.font = .body_r_16
            $0.textAlignment = .center
        }

        nextButton.do {
            configureButton($0, normalImage: .icChevronRightSmWhite, disabledImage: .icChevronRightSmGrey)
        }
    }

    override func setUI() {
        addSubview(stackView)
        stackView.addArrangedSubviews(previousButton, monthLabel, nextButton)
    }

    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        previousButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        nextButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        monthLabel.snp.makeConstraints {
            $0.height.equalTo(22)
        }
    }

    func configure(
        title: String,
        canMoveToPreviousMonth: Bool,
        canMoveToNextMonth: Bool
    ) {
        monthLabel.text = title
        updateButton(previousButton, isEnabled: canMoveToPreviousMonth)
        updateButton(nextButton, isEnabled: canMoveToNextMonth)
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

    private func updateButton(_ button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
    }

    private func configureButton(_ button: UIButton, normalImage: UIImage, disabledImage: UIImage) {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        configuration.image = normalImage
        button.configuration = configuration

        button.configurationUpdateHandler = { button in
            var updatedConfiguration = button.configuration
            updatedConfiguration?.image = button.isEnabled ? normalImage : disabledImage
            button.configuration = updatedConfiguration
        }
    }
}
