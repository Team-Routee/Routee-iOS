//
//  SettingToastPresentable.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

import SnapKit

protocol SettingToastPresentable where Self: UIView { }

extension SettingToastPresentable {
    func showToast(title: String) {
        subviews
            .filter { $0 is ToastMessageView }
            .forEach { $0.removeFromSuperview() }

        let toastMessageView = ToastMessageView(title: title)

        addSubview(toastMessageView)
        layoutIfNeeded()

        let toastWidth = min(
            toastMessageView.titleLabel.intrinsicContentSize.width + 32,
            bounds.width - 48
        )

        toastMessageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            $0.width.equalTo(toastWidth)
            $0.height.equalTo(37)
        }

        toastMessageView.layer.cornerRadius = 12
        toastMessageView.clipsToBounds = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.2) {
                toastMessageView.alpha = 0
            } completion: { _ in
                toastMessageView.removeFromSuperview()
            }
        }
    }
}
