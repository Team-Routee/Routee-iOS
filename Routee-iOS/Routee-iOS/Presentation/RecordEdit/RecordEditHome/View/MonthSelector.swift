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
    
    // MARK: - init
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setAddTarget()
        updateMonthState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Settings
    
    override func setStyle() {
        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
        
        leftButton.do {
            $0.setImage(UIImage(named: "ic_chevron_left_sm_white"), for: .normal)
        }
        
        monthLabel.do {
            $0.text = "2026년 3월"
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }
        
        rightButton.do {
            $0.setImage(UIImage(named: "ic_chevron_right_sm_white"), for: .normal)
            $0.setImage(UIImage(named: "ic_chevron_right_sm_grey"), for: .disabled)
        }
    }
    
    override func setUI() {
        addSubview(stackView)
        
        stackView.addArrangedSubviews(
            leftButton, monthLabel, rightButton
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
        rightButton.isEnabled = !currentDate.isSameMonth(as: Date())
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapPrevious() {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: currentDate
        ) else { return }

        currentDate = date.startOfMonth
    }
    
    @objc
    private func didTapNext() {
        guard !currentDate.isSameMonth(as: Date()) else { return }
        
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: currentDate
        ) else { return }

        currentDate = date.startOfMonth
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
}
