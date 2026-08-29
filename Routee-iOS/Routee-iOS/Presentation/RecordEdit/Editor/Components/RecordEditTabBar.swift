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
    var onBrightnessTap: (() -> Void)?
    var onColorTap: (() -> Void)?
    var onStickerTap: (() -> Void)?
    var onBrightnessChanged: ((CGFloat) -> Void)?
    var onColorSelected: ((UIColor) -> Void)?
    var onStickerSelected: ((StickerSelector.StickerType) -> Void)?
    var onStickerEditingChanged: ((Bool) -> Void)?
    var onOptionViewVisibilityChanged: ((Bool) -> Void)?
    
    private lazy var tabItems: [RecordEditTabBarItem] = {
        [backgroundItem, brightnessItem, colorItem, stickerItem]
    }()
    private var tabItemsWidth: CGFloat {
        CGFloat(tabItems.count) * 84
    }

    private enum OptionView {
        case brightness
        case color
        case sticker
    }
    
    // MARK: - UI Properties
    
    private let buttonStackView = UIStackView()
    private let backgroundItem = RecordEditTabBarItem(
        title: "배경 변경",
        normalImage: .icChangeBgSmGrey,
        selectedImage: .icChangeBgSmWhite
    )
    private let brightnessItem = RecordEditTabBarItem(
        title: "밝기",
        normalImage: .icBrightnessSmGrey,
        selectedImage: .icBrightnessSmWhite
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
    private let brightnessSliderView = BrightnessSliderView()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .dimSecondary
        
        brightnessSliderView.isHidden = true
        colorPalette.isHidden = true
        stickerSelector.isHidden = true
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.alignment = .leading
            $0.spacing = 0
        }
    }
    
    override func setUI() {
        addSubviews(brightnessSliderView, colorPalette, stickerSelector, buttonStackView)
        
        buttonStackView.addArrangedSubviews(
            backgroundItem,
            brightnessItem,
            colorItem,
            stickerItem
        )
        
        setActions()
    }
    
    override func setLayout() {
        brightnessSliderView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(snp.top)
            $0.height.equalTo(42)
        }

        colorPalette.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(snp.top)
            $0.height.equalTo(48)
        }
        
        stickerSelector.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(snp.top)
            $0.height.equalTo(48)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(tabItemsWidth)
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
        hideOptionViews()
        tabItems.forEach { $0.isSelected = false }
    }

    func setBrightnessValue(_ value: CGFloat) {
        brightnessSliderView.setValue(value)
    }
    
    func containsInteractivePoint(_ point: CGPoint) -> Bool {
        if bounds.contains(point) {
            return true
        }
        
        let palettePoint = colorPalette.convert(point, from: self)
        let stickerPoint = stickerSelector.convert(point, from: self)
        let brightnessPoint = brightnessSliderView.convert(point, from: self)
        
        return (!colorPalette.isHidden && colorPalette.bounds.contains(palettePoint))
        || (!stickerSelector.isHidden && stickerSelector.bounds.contains(stickerPoint))
        || (!brightnessSliderView.isHidden && brightnessSliderView.bounds.contains(brightnessPoint))
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0, isUserInteractionEnabled else { return nil }
        
        let palettePoint = colorPalette.convert(point, from: self)
        
        if !colorPalette.isHidden,
           let paletteHitView = colorPalette.hitTest(palettePoint, with: event) {
            return paletteHitView
        }

        let brightnessPoint = brightnessSliderView.convert(point, from: self)

        if !brightnessSliderView.isHidden,
           let brightnessHitView = brightnessSliderView.hitTest(brightnessPoint, with: event) {
            return brightnessHitView
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
        brightnessItem.addTarget(self, action: #selector(brightnessButtonTapped), for: .touchUpInside)
        colorItem.addTarget(self, action: #selector(colorButtonTapped), for: .touchUpInside)
        stickerItem.addTarget(self, action: #selector(stickerButtonTapped), for: .touchUpInside)
        
        colorPalette.onColorSelected = { [weak self] color in self?.onColorSelected?(color) }

        brightnessSliderView.onValueChanged = { [weak self] value in
            self?.onBrightnessChanged?(value)
        }
        
        stickerSelector.onStickerSelected = { [weak self] sticker in self?.onStickerSelected?(sticker) }
    }
    
    private func selectItem(_ selectedItem: RecordEditTabBarItem) {
        tabItems.forEach {
            $0.isSelected = ($0 === selectedItem)
        }
    }

    private func hideOptionViews(except visibleOptionView: OptionView? = nil) {
        brightnessSliderView.isHidden = visibleOptionView != .brightness
        colorPalette.isHidden = visibleOptionView != .color
        stickerSelector.isHidden = visibleOptionView != .sticker
        onOptionViewVisibilityChanged?(visibleOptionView != nil)

        if visibleOptionView != .sticker {
            stickerSelector.deselectAll()
            onStickerEditingChanged?(false)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func colorButtonTapped() {
        let shouldShowColorPalette = colorPalette.isHidden

        hideOptionViews(except: shouldShowColorPalette ? .color : nil)
        onColorTap?()

        if shouldShowColorPalette {
            selectItem(colorItem)
        } else {
            tabItems.forEach { $0.isSelected = false }
        }
    }
    
    @objc
    private func stickerButtonTapped() {
        let shouldShowStickerSelector = stickerSelector.isHidden

        hideOptionViews(except: shouldShowStickerSelector ? .sticker : nil)
        onStickerTap?()

        if shouldShowStickerSelector {
            selectItem(stickerItem)
            stickerSelector.deselectAll()
            onStickerEditingChanged?(true)
        } else {
            tabItems.forEach { $0.isSelected = false }
        }
    }
    
    @objc
    private func backgroundButtonTapped() {
        selectItem(backgroundItem)
        hideOptionView()
        onBackgroundTap?()
    }

    @objc
    private func brightnessButtonTapped() {
        let shouldShowBrightnessSlider = brightnessSliderView.isHidden

        hideOptionViews(except: shouldShowBrightnessSlider ? .brightness : nil)

        if shouldShowBrightnessSlider {
            selectItem(brightnessItem)
            onBrightnessTap?()
        } else {
            tabItems.forEach { $0.isSelected = false }
        }
    }
}
