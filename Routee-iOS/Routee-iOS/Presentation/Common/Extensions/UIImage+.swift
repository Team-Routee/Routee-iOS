//
//  UIImage+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func thumbnailImage(
        borderWidth: CGFloat,
        borderColor: UIColor,
        cornerRadius: CGFloat
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)
            let clipPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            clipPath.addClip()
            draw(in: rect)

            let borderRect = rect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
            let borderPath = UIBezierPath(
                roundedRect: borderRect,
                cornerRadius: max(cornerRadius - borderWidth / 2, 0)
            )
            borderPath.lineWidth = borderWidth
            borderColor.setStroke()
            borderPath.stroke()
        }
    }
}
