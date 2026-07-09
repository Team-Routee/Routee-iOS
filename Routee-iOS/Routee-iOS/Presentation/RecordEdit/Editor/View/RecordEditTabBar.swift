//
//  RecordEditTabBar.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class RecordEditTabBar: BaseUIView {
    
    // MARK: - Properties
    
    var onBackgroundTap: (() -> Void)?
    var onColorTap: (() -> Void)?
    var onStickerTap: (() -> Void)?
    var onColorSelected: ((UIColor) -> Void)?
    
    private lazy var tabItems: [RecordEditTabBarItem] = {
        [backgroundItem, colorItem, stickerItem]
    }()
    
    // MARK: - UI Properties
    
    private let buttonStackView = UIStackView()
    private let backgroundItem = RecordEditTabBarItem(
        title: "배경 변경",
        normalImage: .icChangeBgSmGrey,
        selectedImage: .icChangeBgSmWhite
    )
    private let colorItem = RecordEditTabBarItem(
        title: "색상 변경",
        normalImage: .icChangeColorSmGrey,
        selectedImage: .icChangeColorSmWhite
    )
    private let stickerItem = RecordEditTabBarItem(
        title: "스티커",
        normalImage: .icStickerSmGrey,
        selectedImage: .icStickerSmWhite
    )
    private let colorChipStackView = UIStackView()
    // 컬러칩, 스티커 부분 추가해야댐
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .dimSecondary
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 0
        }
    }
    
    override func setUI() {
        addSubviews(buttonStackView)
        
        buttonStackView.addArrangedSubviews(
            backgroundItem,
            colorItem,
            stickerItem
        )
        
        backgroundItem.addTarget(self, action: #selector(backgroundButtonTapped), for: .touchUpInside)
        colorItem.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        stickerItem.addTarget(self, action: #selector(stickerButtonTapped), for: .touchUpInside)
    }
    
    override func setLayout() {
        buttonStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        tabItems.forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(84)
                $0.height.equalTo(71)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func selectItem(_ selectedItem: RecordEditTabBarItem) {
        tabItems.forEach {
            $0.isSelected = ($0 === selectedItem)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func colorButtonTapped() {
        selectItem(colorItem)
        colorChipStackView.isHidden.toggle()
        onColorTap?()
    }
    
    @objc
    private func stickerButtonTapped() {
        selectItem(stickerItem)
        onStickerTap?()
    }
    
    @objc
    private func backgroundButtonTapped() {
        selectItem(backgroundItem)
        onBackgroundTap?()
    }
}
