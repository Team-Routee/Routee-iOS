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
}
