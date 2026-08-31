//
//  ToastMessageView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class ToastMessageView: BaseUIView {
    
    // MARK: - UI Properties
    
    let titleLabel = UILabel()
    
    // MARK: - init
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .grey_800
        
        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_m_14
            $0.textAlignment = .center
            $0.lineBreakMode = .byTruncatingTail
        }
    }   
    
    override func setUI() {
        addSubview(titleLabel)
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}

extension ToastMessageView {
    static func show(
        title: String,
        in parentView: UIView,
        bottomAnchor: ConstraintItem,
        bottomOffset: CGFloat = -15
    ) {
        parentView.subviews
            .filter { $0 is ToastMessageView }
            .forEach { $0.removeFromSuperview() }

        let toastMessageView = ToastMessageView(title: title)

        parentView.addSubview(toastMessageView)
        parentView.layoutIfNeeded()

        let toastWidth = min(
            toastMessageView.titleLabel.intrinsicContentSize.width + 32,
            parentView.bounds.width - 48
        )

        toastMessageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomAnchor).offset(bottomOffset)
            $0.width.equalTo(toastWidth)
            $0.height.equalTo(37)
        }

        toastMessageView.layer.cornerRadius = 12
        toastMessageView.clipsToBounds = true

        UIView.animate(withDuration: 1.5) {
            toastMessageView.alpha = 0
        } completion: { _ in
            toastMessageView.removeFromSuperview()
        }
    }
}
