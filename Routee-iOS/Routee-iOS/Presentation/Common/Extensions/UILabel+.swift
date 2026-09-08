//
//  UILabel+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/7/26.
//

import UIKit

extension UILabel {
    func setDisplayText(_ text: String?, font: UIFont) {
        self.font = font

        guard let text else {
            attributedText = nil
            return
        }

        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [.font: font]
        )
        let letterSpacingLength = max(0, attributedString.length - 1)

        if letterSpacingLength > 0 {
            attributedString.addAttribute(
                .kern,
                value: font.pointSize * 0.04,
                range: NSRange(location: 0, length: letterSpacingLength)
            )
        }

        attributedText = attributedString
    }
}
