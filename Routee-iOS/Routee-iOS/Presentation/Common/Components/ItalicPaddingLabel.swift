//
//  ItalicPaddingLabel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class ItalicPaddingLabel: UILabel {
    private let rightPadding: CGFloat = 2

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + rightPadding,
            height: size.height
        )
    }
}
