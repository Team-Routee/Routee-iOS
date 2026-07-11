//
//  UIView+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/27/26.
//

import UIKit

import SnapKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    func showToast(title: String) {
        subviews
            .compactMap { $0 as? ToastMessageView }
            .forEach { $0.removeFromSuperview() }
        
        let toastMessageView = ToastMessageView(title: title)
        addSubview(toastMessageView)
        
        let maxWidth = max(bounds.width - 48, 0)
        let toastWidth = min(
            toastMessageView.titleLabel.intrinsicContentSize.width + 32,
            maxWidth
        )

        toastMessageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(180)
            $0.height.equalTo(37)
            $0.width.equalTo(toastWidth)
        }

        toastMessageView.layer.cornerRadius = 12
        toastMessageView.clipsToBounds = true
        toastMessageView.alpha = 1

        UIView.animate(withDuration: 1.5) {
            toastMessageView.alpha = 0
        } completion: { _ in
            toastMessageView.removeFromSuperview()
        }
    }
}
