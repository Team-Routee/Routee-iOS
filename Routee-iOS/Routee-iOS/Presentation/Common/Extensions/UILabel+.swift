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
