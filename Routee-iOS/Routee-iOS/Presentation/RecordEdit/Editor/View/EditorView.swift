//
//  EditorView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class EditorView: BaseUIView {

    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    let topNavigationBar = TopNavigationBar(rightTitle: "완료")
    private let backgroundOpacityView = UIView()
    private let backgroundImageView = UIImageView()
    private let dataInfo = RecordInfo()
    private let recordEditTabBar = RecordEditTabBar()
    private let routeSticker = RouteSticker()
    private lazy var stickerBox = StickerBox(contentView: routeSticker)
    private lazy var hideOptionViewTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleViewTapped(_:))
    )

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary
        hideOptionViewTapGesture.cancelsTouchesInView = false
        
        backgroundOpacityView.do {
            $0.backgroundColor = .black40
        }

        backgroundImageView.do {
            $0.image = UIImage(resource: .imgNavermapMain)
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
    }

    override func setUI() {
        addSubviews(
            backgroundGradientView,
            backgroundImageView,
            backgroundOpacityView,
            dataInfo,
            topNavigationBar,
            recordEditTabBar
        )

        addGestureRecognizer(hideOptionViewTapGesture)
        setStickerAction()
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        recordEditTabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(71)
        }
        
        backgroundOpacityView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(12)
            $0.bottom.equalTo(recordEditTabBar.snp.top)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(12)
            $0.bottom.equalTo(recordEditTabBar.snp.top)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        dataInfo.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.top).offset(80)
            $0.leading.equalTo(backgroundImageView.snp.leading).offset(32)
            $0.height.equalTo(164)
            $0.width.equalTo(85)
        }
    }
    
    // MARK: - Public Methods
    
    func updateBackgroundImage(_ image: UIImage) {
        backgroundImageView.image = image
    }
    
    func setBackgroundTapAction(_ action: @escaping () -> Void) {
        recordEditTabBar.onBackgroundTap = action
    }
    
    func makeEditedImage() -> UIImage {
        stickerBox.setCloseButton(isSelected: false)
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
    
    func addSticker(_ contentView: UIView) {
        let stickerBox = StickerBox(contentView: contentView)

        addSubview(stickerBox)
        let stickerSize = stickerBoxSize(for: stickerBox)

        stickerBox.frame = CGRect(
            x: 100,
            y: 200,
            width: stickerSize.width,
            height: stickerSize.height
        )
        
        stickerBox.onDeleted = { [weak stickerBox] in
            stickerBox?.removeFromSuperview()
        }
    }

    // MARK: - Private Methods

    private func setStickerAction() {
        recordEditTabBar.onStickerSelected = { [weak self] stickerType in
            guard stickerType == .route else { return }
            self?.showRouteSticker()
        }
    }

    private func showRouteSticker() {
        guard stickerBox.superview == nil else {
            bringSubviewToFront(stickerBox)
            return
        }

        addSubview(stickerBox)
        let stickerSize = stickerBoxSize(for: stickerBox)

        stickerBox.frame = CGRect(
            x: 100,
            y: 200,
            width: stickerSize.width,
            height: stickerSize.height
        )

        stickerBox.onDeleted = { [weak self] in
            self?.stickerBox.removeFromSuperview()
        }
    }
    
    private func stickerBoxSize(for stickerBox: StickerBox) -> CGSize {
        stickerBox.setNeedsLayout()
        stickerBox.layoutIfNeeded()
        
        return stickerBox.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    // MARK: - Actions

    @objc
    private func handleViewTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: recordEditTabBar)
        let stickerPoint = gesture.location(in: stickerBox)

        guard !recordEditTabBar.containsInteractivePoint(point) else { return }
        
        if stickerBox.superview != nil,
           stickerBox.isSelected,
           !stickerBox.bounds.contains(stickerPoint) {
            stickerBox.setCloseButton(isSelected: false)
        }

        recordEditTabBar.hideOptionView()
    }
}
