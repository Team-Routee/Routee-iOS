//
//  TabBarItem.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/5/26.
//
import UIKit

import SnapKit
import Then

final class TabBarItem: UIControl {

    // MARK: - Properties

    private var normalImage: UIImage?
    private var selectedImage: UIImage?

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - UI Properties

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    private lazy var contentStackView = UIStackView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    private func setStyle() {
        imageView.do {
            $0.contentMode = .scaleAspectFit
        }

        titleLabel.do {
            $0.font = .label_m_12
            $0.textAlignment = .center
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 0
            $0.isUserInteractionEnabled = false
        }
    }

    private func setUI() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubviews(imageView, titleLabel)
    }

    private func setLayout() {
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(17)
        }
    }
    
    // MARK: - Public Methods

    func configure(normalImage: UIImage, selectedImage: UIImage, title: String) {
        self.normalImage = normalImage
        self.selectedImage = selectedImage

        titleLabel.text = title

        updateAppearance()
    }

    // MARK: - Private Methods

    private func updateAppearance() {
        imageView.image = isSelected ? selectedImage : normalImage
        titleLabel.textColor = isSelected ? .staticWhite : .grey400
    }
}
