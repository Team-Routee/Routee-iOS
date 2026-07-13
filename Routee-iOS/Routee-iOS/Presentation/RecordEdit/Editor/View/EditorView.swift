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

    // MARK: - Properties

    private let stickerHorizontalInset: CGFloat = 13
    private let stickerVerticalInset: CGFloat = 10
    private let stickerMovementInset: CGFloat = 12
    private var state = EditorState()

    private struct EditorState {
        var selectedColor: UIColor = .recapMint
        var didSetRouteTimelineStickerFrame = false
    }

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    let topNavigationBar = TopNavigationBar(rightTitle: "완료")
    private let backgroundOpacityView = UIView()
    private let backgroundImageView = UIImageView()
    private let routeTimelineDrawingView = RouteDrawer()
    private let routeSticker = RouteSticker()
    private let dataInfo = RecordInfo()
    private let recordEditTabBar = RecordEditTabBar()
    private let lottieOverlayView = LottieOverlayView()
    private lazy var routeTimelineStickerBox = StickerBox(contentView: routeTimelineDrawingView)
    private lazy var routeStickerBox = StickerBox(contentView: routeSticker)
    private lazy var hideOptionViewTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleViewTapped(_:))
    )

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary
        hideOptionViewTapGesture.cancelsTouchesInView = false

        backgroundOpacityView.do {
            $0.backgroundColor = .black50
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
            routeTimelineStickerBox,
            dataInfo,
            topNavigationBar,
            recordEditTabBar,
            lottieOverlayView
        )

        addGestureRecognizer(hideOptionViewTapGesture)
        setColorAction()
        setStickerAction()
        setInitialRouteTimelineSticker()
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

        lottieOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateStickerMovementBounds()
        setRouteTimelineStickerFrame()
    }

    // MARK: - Public Methods

    func updateBackgroundImage(_ image: UIImage) {
        backgroundImageView.image = image
        backgroundOpacityView.backgroundColor = .black40
    }

    func setBackgroundTapAction(_ action: @escaping () -> Void) {
        recordEditTabBar.onBackgroundTap = action
    }

    func makeEditedImage() -> UIImage {
        routeTimelineStickerBox.setCloseButton(isSelected: false)
        routeStickerBox.setCloseButton(isSelected: false)
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

    func playLottie(completion: @escaping () -> Void) {
        lottieOverlayView.play(completion: completion)
    }

    // MARK: - Private Methods

    private func setColorAction() {
        recordEditTabBar.onColorSelected = { [weak self] color in
            self?.updateEditorColor(color)
        }
    }

    private func updateEditorColor(_ color: UIColor) {
        state.selectedColor = color
        dataInfo.updateColor(color)
        routeTimelineDrawingView.updateColor(color)
        routeSticker.updateColor(color)
    }

    private func setStickerAction() {
        recordEditTabBar.onStickerEditingChanged = { [weak self] isEnabled in
            self?.setStickerEditingEnabled(isEnabled)
        }

        recordEditTabBar.onStickerSelected = { [weak self] stickerType in
            switch stickerType {
            case .photoTimeline:
                self?.selectRouteTimelineSticker()
            case .route:
                self?.showRouteSticker()
            }
        }
    }

    private func setInitialRouteTimelineSticker() {
        deactivateStickerBox(routeTimelineStickerBox)

        routeTimelineStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            self.removeStickerBox(self.routeTimelineStickerBox)
        }
    }

    private func setStickerEditingEnabled(_ isEnabled: Bool) {
        if !isEnabled {
            deactivateStickerBox(routeTimelineStickerBox)
            deactivateStickerBox(routeStickerBox)
            return
        }

        routeTimelineStickerBox.isUserInteractionEnabled = routeTimelineStickerBox.superview != nil
        routeStickerBox.isUserInteractionEnabled = routeStickerBox.superview != nil
    }

    private func selectRouteTimelineSticker() {
        removeStickerBox(routeStickerBox)

        if routeTimelineStickerBox.superview == nil {
            addSubview(routeTimelineStickerBox)
            updateRouteTimelineStickerFrame()
        }

        activateStickerBox(routeTimelineStickerBox)
    }

    private func showRouteSticker() {
        removeStickerBox(routeTimelineStickerBox)

        guard routeStickerBox.superview == nil else {
            activateStickerBox(routeStickerBox)
            return
        }

        addSubview(routeStickerBox)
        layoutIfNeeded()
        routeSticker.updateColor(state.selectedColor)

        let stickerSize = stickerBoxSize(for: routeStickerBox)

        routeStickerBox.frame = CGRect(
            x: dataInfo.frame.minX - 8,
            y: dataInfo.frame.maxY + 11,
            width: stickerSize.width,
            height: stickerSize.height
        )

        routeStickerBox.onDeleted = { [weak self] in
            guard let self else { return }
            self.removeStickerBox(self.routeStickerBox)
        }

        activateStickerBox(routeStickerBox)
    }

    private func updateStickerMovementBounds() {
        let movementBounds = backgroundImageView.frame.insetBy(
            dx: stickerMovementInset,
            dy: stickerMovementInset
        )

        routeTimelineStickerBox.movementBounds = movementBounds
        routeStickerBox.movementBounds = movementBounds
    }

    private func setRouteTimelineStickerFrame() {
        guard !state.didSetRouteTimelineStickerFrame,
              backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        updateRouteTimelineStickerFrame()
        state.didSetRouteTimelineStickerFrame = true
    }

    private func updateRouteTimelineStickerFrame() {
        guard backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        let routePoints = TrackPoint
            .dummyTrackPoints()
            .toCanvasPoints(in: backgroundImageView.bounds.size)

        guard let routeRect = routeTimelineDrawingView.configureSticker(points: routePoints) else { return }

        let stickerHeight = routeRect.height + stickerVerticalInset * 2

        routeTimelineDrawingView.updateColor(state.selectedColor)
        routeTimelineStickerBox.frame = CGRect(
            x: backgroundImageView.frame.minX + routeRect.minX - stickerHorizontalInset,
            y: backgroundImageView.frame.maxY - stickerHeight,
            width: routeRect.width + stickerHorizontalInset * 2,
            height: stickerHeight
        )
    }

    private func activateStickerBox(_ stickerBox: StickerBox) {
        stickerBox.isUserInteractionEnabled = true
        stickerBox.setCloseButton(isSelected: true)
        bringSubviewToFront(stickerBox)
        bringEditorControlsToFront()
    }

    private func deactivateStickerBox(_ stickerBox: StickerBox) {
        stickerBox.setCloseButton(isSelected: false)
        stickerBox.isUserInteractionEnabled = false
    }

    private func removeStickerBox(_ stickerBox: StickerBox) {
        stickerBox.removeFromSuperview()
    }

    private func bringEditorControlsToFront() {
        bringSubviewToFront(topNavigationBar)
        bringSubviewToFront(recordEditTabBar)
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
        let routeTimelineStickerPoint = gesture.location(in: routeTimelineStickerBox)
        let routeStickerPoint = gesture.location(in: routeStickerBox)

        guard !recordEditTabBar.containsInteractivePoint(point) else { return }

        if routeTimelineStickerBox.superview != nil,
           routeTimelineStickerBox.isSelected,
           !routeTimelineStickerBox.bounds.contains(routeTimelineStickerPoint) {
            deactivateStickerBox(routeTimelineStickerBox)
        }

        if routeStickerBox.superview != nil,
           routeStickerBox.isSelected,
           !routeStickerBox.bounds.contains(routeStickerPoint) {
            deactivateStickerBox(routeStickerBox)
        }

        recordEditTabBar.hideOptionView()
    }
}
