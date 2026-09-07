//
//  UILabel+.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 9/7/26.
//

import UIKit

extension UILabel {
    func containsTap(in range: NSRange, at point: CGPoint) -> Bool {
        guard
            let attributedText,
            range.location != NSNotFound
        else { return false }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let textBoundingBox = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        let textOffset = CGPoint(
            x: (bounds.width - textBoundingBox.width) / 2 - textBoundingBox.minX,
            y: (bounds.height - textBoundingBox.height) / 2 - textBoundingBox.minY
        )
        let tapLocation = CGPoint(
            x: point.x - textOffset.x,
            y: point.y - textOffset.y
        )
        let characterIndex = layoutManager.characterIndex(
            for: tapLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(characterIndex, range)
    }
}
