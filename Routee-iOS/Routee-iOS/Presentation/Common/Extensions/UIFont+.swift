//
//  UIFont+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/4/26.
//

import UIKit

// swiftlint:disable identifier_name
extension UIFont {
    enum PretendardWeight {
        case black
        case bold
        case extraBold
        case extraLight
        case light
        case medium
        case regular
        case semiBold
        case thin

        fileprivate var fontName: String {
            switch self {
            case .black:
                "Pretendard-Black"
            case .bold:
                "Pretendard-Bold"
            case .extraBold:
                "Pretendard-ExtraBold"
            case .extraLight:
                "Pretendard-ExtraLight"
            case .light:
                "Pretendard-Light"
            case .medium:
                "Pretendard-Medium"
            case .regular:
                "Pretendard-Regular"
            case .semiBold:
                "Pretendard-SemiBold"
            case .thin:
                "Pretendard-Thin"
            }
        }
    }
    
    enum ArchivoWeight {
        case bold
        case semiBold

        fileprivate var fontName: String {
            switch self {
            case .bold:
                "Archivo-BoldItalic"
            case .semiBold:
                "Archivo-SemiBoldItalic"
            }
        }
    }

    static var display_b_42: UIFont { archivoItalic(.bold, size: 52) }
    
    static var display_sb_28: UIFont { archivoItalic(.semiBold, size: 28) }
    static var display_sb_22: UIFont { archivoItalic(.semiBold, size: 22) }

    static var title_sb_24: UIFont { pretendard(.semiBold, size: 24) }
    static var title_sb_20: UIFont { pretendard(.semiBold, size: 20) }
    static var title_sb_18: UIFont { pretendard(.semiBold, size: 18) }

    static var body_r_16: UIFont { pretendard(.regular, size: 16) }
    static var body_sb_14: UIFont { pretendard(.semiBold, size: 14) }

    static var label_sb_18: UIFont { pretendard(.semiBold, size: 18) }
    static var label_sb_16: UIFont { pretendard(.semiBold, size: 16) }
    static var label_m_16: UIFont { pretendard(.medium, size: 16) }
    static var label_sb_14: UIFont { pretendard(.semiBold, size: 14) }
    static var label_m_14: UIFont { pretendard(.medium, size: 14) }
    static var label_r_14: UIFont { pretendard(.regular, size: 14) }
    static var label_sb_12: UIFont { pretendard(.semiBold, size: 12) }
    static var label_m_12: UIFont { pretendard(.medium, size: 12) }
    static var label_r_12: UIFont { pretendard(.regular, size: 12) }

    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> UIFont {
        UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
    }

    static func archivoItalic(_ weight: ArchivoWeight, size: CGFloat) -> UIFont {
        UIFont(name: weight.fontName, size: size) ?? .italicSystemFont(ofSize: size)
    }
}
// swiftlint:enable identifier_name
