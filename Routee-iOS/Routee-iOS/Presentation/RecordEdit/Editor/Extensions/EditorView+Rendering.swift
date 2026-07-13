//
//  EditorView+Rendering.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import UIKit

extension EditorView {

    // MARK: - Public Methods

    func makeEditedImage() -> UIImage {
        routeTimelineStickerBox.setCloseButton(isSelected: false)
        routeStickerBox.setCloseButton(isSelected: false)
        layoutIfNeeded()

        let renderFrame = backgroundImageView.frame
        let renderer = UIGraphicsImageRenderer(size: renderFrame.size)

        return renderer.image { context in
            context.cgContext.translateBy(
                x: -renderFrame.minX,
                y: -renderFrame.minY
            )
            layer.render(in: context.cgContext)
        }
    }
}
