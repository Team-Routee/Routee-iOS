//
//  ListView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class ListView: BaseUIView {
    
    //MARK: - UI Properties
    
    private let handleView = UIView()
    private let dateLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    //MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .grey900
        layer.cornerRadius = .r24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.grey900.cgColor
        
        handleView.do {
            $0.backgroundColor = .grey300
            $0.layer.cornerRadius = 2
        }
        
        dateLabel.do {
            $0.textColor = .static_white
            $0.font = .label_sb_14
        }
        
        scrollView.do {
            $0.backgroundColor = .grey900
            $0.showsVerticalScrollIndicator = false
            $0.bounces = false
            $0.alwaysBounceVertical = false
            $0.contentInsetAdjustmentBehavior = .never
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
            $0.top.equalToSuperview().inset(12)
            $0.horizontalEdges.equalToSuperview().inset(166)
            $0.height.equalTo(4)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    //MARK: - Public Methods
    
    func configure(with model: ListModel) {
        dateLabel.text = model.dateText
        
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        model.items.forEach { item in
            let itemView = ListItem()
            itemView.configure(with: item)
            stackView.addArrangedSubview(itemView)
        }
        
        let shouldScroll = model.items.count > 3
        scrollView.isScrollEnabled = shouldScroll
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
    }
    static func modalHeight(for itemCount: Int) -> CGFloat {
        itemCount <= 2 ? 247 : 344
    }
}
