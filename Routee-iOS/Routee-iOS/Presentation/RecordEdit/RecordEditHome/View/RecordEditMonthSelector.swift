//
//  MonthSelector.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class MonthSelector: BaseUIView {
    
    // MARK: - Properties

    var onMonthChanged: ((Date) -> Void)?

    private var minimumDate: Date?
    
    private var currentDate = Date().startOfMonth {
        didSet {
            updateMonthState()
        }
    }
    
    // MARK: - UI Properties
    
    private let stackView = UIStackView()
    private let leftButton = UIButton()
    private let monthLabel = UILabel()
    private let rightButton = UIButton()
    
    // MARK: - Initializer
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setAddTarget()
        updateMonthState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
        
        leftButton.do {
            configureButton($0, normalImage: .icChevronLeftSmWhite, disabledImage: .icChevronLeftSmGrey)
        }
        
        monthLabel.do {
            $0.text = "2026년 3월"
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }
        
        rightButton.do {
            configureButton($0, normalImage: .icChevronRightSmWhite, disabledImage: .icChevronRightSmGrey)
        }
    }
    
    override func setUI() {
        addSubview(stackView)
        
        stackView.addArrangedSubviews(
            leftButton,
            monthLabel,
            rightButton
        )
    }
    
    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        leftButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        rightButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"

        monthLabel.text = formatter.string(from: currentDate)
    }
    
    private func updateMonthState() {
        updateMonthLabel()
        updateButton(leftButton, isEnabled: canMoveToPreviousMonth)
        updateButton(rightButton, isEnabled: !currentDate.isSameMonth(as: Date()))
        onMonthChanged?(currentDate)
    }

    private var canMoveToPreviousMonth: Bool {
        guard let minimumDate,
              let previousMonth = Calendar.current.date(
                byAdding: .month,
                value: -1,
                to: currentDate
              )?.startOfMonth else {
            return true
        }

        return previousMonth >= minimumDate
    }
    
    private func setAddTarget() {
        leftButton.addTarget(
            self,
            action: #selector(didTapPrevious),
            for: .touchUpInside
        )
        
        rightButton.addTarget(
            self,
            action: #selector(didTapNext),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapPrevious() {
        guard leftButton.isEnabled else { return }

        guard let date = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: currentDate
        )?.startOfMonth,
              minimumDate.map({ date >= $0 }) ?? true else { return }

        currentDate = date
    }
    
    @objc
    private func didTapNext() {
        guard rightButton.isEnabled else { return }
        
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: currentDate
        ) else { return }

        currentDate = date.startOfMonth
    }

    private func updateButton(_ button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        button.isUserInteractionEnabled = isEnabled
        button.setNeedsUpdateConfiguration()
    }

    // MARK: - Public Methods

    func configureMinimumDate(_ date: Date?) {
        minimumDate = date?.startOfMonth

        if let minimumDate,
           currentDate < minimumDate {
            currentDate = minimumDate
            return
        }

        updateMonthState()
    }

    private func configureButton(_ button: UIButton, normalImage: UIImage, disabledImage: UIImage) {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        configuration.image = normalImage
        button.configuration = configuration
        button.adjustsImageWhenDisabled = false

        button.configurationUpdateHandler = { button in
            var updatedConfiguration = button.configuration
            updatedConfiguration?.image = button.isEnabled ? normalImage : disabledImage
            button.configuration = updatedConfiguration
        }
    }
}
