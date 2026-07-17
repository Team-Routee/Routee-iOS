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
    var onStickerSelected: ((StickerSelector.StickerType) -> Void)?
    var onStickerEditingChanged: ((Bool) -> Void)?
    
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
    private let colorPalette = ColorPalette()
    private let stickerSelector = StickerSelector()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .dimSecondary
        
        colorPalette.isHidden = true
        stickerSelector.isHidden = true
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 0
        }
    }
    
    override func setUI() {
        addSubviews(colorPalette, stickerSelector, buttonStackView)
        
        buttonStackView.addArrangedSubviews(
            backgroundItem,
            colorItem,
            stickerItem
        )
        
        setActions()
    }
    
    override func setLayout() {
        colorPalette.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(snp.top)
            $0.height.equalTo(48)
        }
        
        stickerSelector.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(snp.top)
            $0.height.equalTo(48)
        }
        
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
    
    // MARK: - Public Methods
    
    func hideOptionView() {
        colorPalette.isHidden = true
        stickerSelector.isHidden = true
        stickerSelector.deselectAll()
        tabItems.forEach { $0.isSelected = false }
        onStickerEditingChanged?(false)
    }
    
    func containsInteractivePoint(_ point: CGPoint) -> Bool {
        if bounds.contains(point) {
            return true
        }
        
        let palettePoint = colorPalette.convert(point, from: self)
        let stickerPoint = stickerSelector.convert(point, from: self)
        
        return (!colorPalette.isHidden && colorPalette.bounds.contains(palettePoint))
        || (!stickerSelector.isHidden && stickerSelector.bounds.contains(stickerPoint))
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0, isUserInteractionEnabled else { return nil }
        
        let palettePoint = colorPalette.convert(point, from: self)
        
        if !colorPalette.isHidden,
           let paletteHitView = colorPalette.hitTest(palettePoint, with: event) {
            return paletteHitView
        }
        
        let stickerPoint = stickerSelector.convert(point, from: self)
        
        if !stickerSelector.isHidden,
           let stickerHitView = stickerSelector.hitTest(stickerPoint, with: event) {
            return stickerHitView
        }
        
        return super.hitTest(point, with: event)
    }
    
    // MARK: - Private Methods
    
    private func setActions() {
        backgroundItem.addTarget(self, action: #selector(backgroundButtonTapped), for: .touchUpInside)
        colorItem.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        stickerItem.addTarget(self, action: #selector(stickerButtonTapped), for: .touchUpInside)
        
        colorPalette.onColorSelected = { [weak self] color in self?.onColorSelected?(color) }
        
        stickerSelector.onStickerSelected = { [weak self] sticker in self?.onStickerSelected?(sticker) }
    }
    
    private func selectItem(_ selectedItem: RecordEditTabBarItem) {
        tabItems.forEach {
            $0.isSelected = ($0 === selectedItem)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func colorButtonTapped() {
        stickerSelector.isHidden = true
        stickerSelector.deselectAll()
        onStickerEditingChanged?(false)
        onColorTap?()
        
        if colorPalette.isHidden {
            selectItem(colorItem)
            colorPalette.isHidden = false
        } else {
            tabItems.forEach { $0.isSelected = false }
            colorPalette.isHidden = true
        }
    }
    
    @objc
    private func stickerButtonTapped() {
        colorPalette.isHidden = true
        onStickerTap?()
        
        if stickerSelector.isHidden {
            selectItem(stickerItem)
            stickerSelector.deselectAll()
            stickerSelector.isHidden = false
            onStickerEditingChanged?(true)
        } else {
            tabItems.forEach { $0.isSelected = false }
            stickerSelector.isHidden = true
            stickerSelector.deselectAll()
            onStickerEditingChanged?(false)
        }
    }
    
    @objc
    private func backgroundButtonTapped() {
        selectItem(backgroundItem)
        hideOptionView()
        onBackgroundTap?()
    }
}
