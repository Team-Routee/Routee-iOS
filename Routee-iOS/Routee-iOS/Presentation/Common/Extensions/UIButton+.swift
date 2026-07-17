//
//  UIButton+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/17/26.
//

import UIKit

extension UIButton {
    func setImageTitle(
        title: String,
        image: UIImage,
        font: UIFont,
        foregroundColor: UIColor,
        imagePadding: CGFloat
    ) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = image
        configuration.imagePadding = imagePadding
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: font])
        )
        configuration.baseForegroundColor = foregroundColor
        self.configuration = configuration
    }
}
