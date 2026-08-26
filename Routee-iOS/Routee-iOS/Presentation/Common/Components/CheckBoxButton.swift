//
//  CheckBoxButton.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/26/26.
//

import UIKit

import SnapKit

enum CheckBoxPrefixStyle {
    case none
    case required
    case optional

    var text: String? {
        switch self {
        case .none:
            nil
        case .required:
            "[필수]"
        case .optional:
            "[선택]"
        }
    }

    var color: UIColor {
        switch self {
        case .required:
                .mint300
        default:
                .grey50
        }
    }

    var titleColor: UIColor {
        switch self {
        case .none:
            .staticWhite
        case .required, .optional:
            .grey50
        }
    }
}

enum CheckBoxFontStyle {
    case labelR14
    case labelSB16

    var font: UIFont {
        switch self {
        case .labelR14:
            .label_r_14
        case .labelSB16:
            .label_sb_16
        }
    }
}

final class CheckBoxButton: UIControl {
    private let checkImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronButton = UIButton()

    var isChecked: Bool {
        get { isSelected }
        set { isSelected = newValue }
    }

    override var isSelected: Bool {
        didSet {
            updateCheckImage()
        }
    }

    init(
        titleText: String = "",
        prefixStyle: CheckBoxPrefixStyle = .none,
        isChecked: Bool = false,
        showsChevron: Bool = false,
        fontStyle: CheckBoxFontStyle = .labelR14
    ) {
        super.init(frame: .zero)

        configureStyle(
            titleText: titleText,
            prefixStyle: prefixStyle,
            fontStyle: fontStyle
        )
        configureHierarchy(showsChevron: showsChevron)
        configureLayout(showsChevron: showsChevron)

        self.isChecked = isChecked

        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChevronAction(target: Any?, action: Selector) {
        chevronButton.addTarget(target, action: action, for: .touchUpInside)
    }

    @objc
    private func didTapButton() {
        isChecked.toggle()
        sendActions(for: .valueChanged)
    }

    private func configureStyle(
        titleText: String,
        prefixStyle: CheckBoxPrefixStyle,
        fontStyle: CheckBoxFontStyle
    ) {
        checkImageView.contentMode = .scaleAspectFit

        titleLabel.attributedText = makeAttributedTitle(
            titleText: titleText,
            prefixStyle: prefixStyle,
            font: fontStyle.font
        )

        chevronButton.setImage(.icChevronRightSmWhite, for: .normal)
        chevronButton.imageView?.contentMode = .scaleAspectFit
    }

    private func configureHierarchy(showsChevron: Bool) {
        addSubviews(checkImageView, titleLabel, chevronButton)
        chevronButton.isHidden = !showsChevron
        chevronButton.isUserInteractionEnabled = showsChevron
    }

    private func configureLayout(showsChevron: Bool) {
        snp.makeConstraints {
            $0.height.equalTo(24)
        }

        checkImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()

            if showsChevron {
                $0.trailing.lessThanOrEqualTo(chevronButton.snp.leading).offset(-12)
            } else {
                $0.trailing.lessThanOrEqualToSuperview()
            }
        }

        if showsChevron {
            chevronButton.snp.makeConstraints {
                $0.trailing.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }
        }
    }

    private func updateCheckImage() {
        checkImageView.image = isChecked ? .checked : .unchecked
    }

    private func makeAttributedTitle(
        titleText: String,
        prefixStyle: CheckBoxPrefixStyle,
        font: UIFont
    ) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString()

        if let prefixText = prefixStyle.text {
            attributedTitle.append(
                NSAttributedString(
                    string: "\(prefixText) ",
                    attributes: [
                        .font: font,
                        .foregroundColor: prefixStyle.color
                    ]
                )
            )
        }

        attributedTitle.append(
            NSAttributedString(
                string: titleText,
                attributes: [
                    .font: font,
                    .foregroundColor: prefixStyle.titleColor
                ]
            )
        )

        return attributedTitle
    }
}
