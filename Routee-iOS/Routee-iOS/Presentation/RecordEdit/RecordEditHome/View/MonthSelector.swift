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

    private var currentDate = Date() {
        didSet {
            updateMonthLabel()
        }
    }
    
    // MARK: - UI Properties
    
    private let stackView = UIStackView()
    private let leftButton = UIButton()
    private let monthLabel = UILabel()
    private let rightButton = UIButton()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
        updateMonthLabel()
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
        formatter.dateFormat = "yyyy년 M월"   // 2026년 7월

        monthLabel.text = formatter.string(from: currentDate)
    }
    
    @objc
    private func didTapPrevious() {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: currentDate
        ) else { return }

        currentDate = date
    }
    
    @objc
    private func didTapNext() {
        guard let date = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: currentDate
        ) else { return }

        currentDate = date
    }
    
    private func AddTarget(_ button: UIButton, _ selector: Selector) {
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
