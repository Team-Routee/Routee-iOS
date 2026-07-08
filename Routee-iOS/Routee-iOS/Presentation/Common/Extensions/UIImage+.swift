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
}
