//
//  EditorView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class EditorView: BaseUIView {

    // MARK: - Properties

    private let recordInfoStickerInsets = UIEdgeInsets(top: 15, left: 17, bottom: 12, right: 23)
    private let timelineStickerInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
    private let routeStickerInsets = UIEdgeInsets(top: 16, left: 14, bottom: 13, right: 9)
    private let stickerMovementInset: CGFloat = 12
    private let timelineStickerBottomOffset: CGFloat = 36
    private let recordInfoContentSize = CGSize(width: 120, height: 164)
    private let resetButtonSize: CGFloat = 36
    private let resetButtonLeadingOffset: CGFloat = 32
    private let resetButtonBottomOffset: CGFloat = 18
    private var state = EditorState()

    private struct EditorState {
        var selectedColor: UIColor = .recapMint
        var backgroundOpacityBase: CGFloat = 0.5
        var backgroundOpacity: CGFloat = 0.5
        var hasChanges = false
        var didSetRecordInfoStickerFrame = false
        var didSetRouteTimelineStickerFrame = false
        var initialBackgroundImageURL = ""
        var trackPoints: [TrackPoint] = TrackPoint.dummyTrackPoints()
        var timelineMarkers: [TimelineMarkerModel] = []
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
    private let resetButton = UIButton(type: .custom)
    private let lottieOverlayView = LottieOverlayView()
    private lazy var recordInfoStickerBox = StickerBox(
        contentView: dataInfo,
        contentInsets: recordInfoStickerInsets
    )
    private lazy var routeTimelineStickerBox = StickerBox(contentView: routeTimelineDrawingView)
    private lazy var routeStickerBox = StickerBox(
        contentView: routeSticker,
        contentInsets: routeStickerInsets
    )
    private lazy var hideOptionViewTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleViewTapped(_:))
    )

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary
        backgroundOpacityView.do {
            $0.backgroundColor = UIColor.staticBlack.withAlphaComponent(state.backgroundOpacity)
        }

        backgroundImageView.do {
            $0.image = .imgNavermapMain
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }

        resetButton.do {
            $0.backgroundColor = .bgPrimary
            $0.layer.cornerRadius = resetButtonSize / 2
            $0.clipsToBounds = true
            $0.adjustsImageWhenDisabled = false
            $0.imageView?.contentMode = .scaleAspectFit
            $0.setImage(.icResetSmWhite.withRenderingMode(.alwaysOriginal), for: .normal)
            $0.setImage(.icResetSmGrey.withRenderingMode(.alwaysOriginal), for: .disabled)
            $0.isEnabled = state.hasChanges
        }
    }

    override func setUI() {
        addSubviews(
            backgroundGradientView,
            backgroundImageView,
            backgroundOpacityView,
            recordInfoStickerBox,
            routeTimelineStickerBox,
            topNavigationBar,
            recordEditTabBar,
            resetButton,
            lottieOverlayView
        )
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
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(71)
        }

        backgroundOpacityView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(12)
            $0.bottom.equalTo(recordEditTabBar.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(12)
            $0.bottom.equalTo(recordEditTabBar.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        resetButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(resetButtonLeadingOffset)
            $0.bottom.equalTo(recordEditTabBar.snp.top).offset(-resetButtonBottomOffset)
            $0.size.equalTo(resetButtonSize)
        }

        lottieOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMoveBounds()
        setRecordInfoFrame()
        setTimelineFrame()
    }

    // MARK: - Public Methods

    var hasChanges: Bool {
        state.hasChanges
    }

    func updateBackgroundImage(_ image: UIImage) {
        backgroundImageView.image = image
        state.backgroundOpacityBase = 0.4
        setBackgroundOpacity(state.backgroundOpacityBase, marksChange: false)
        recordEditTabBar.setBrightnessValue(0.5)
        markChanged()
    }

    func configure(with model: ActivityEditorModel) {
        state.trackPoints = model.trackPoints
        state.timelineMarkers = model.timelineMarkers
        state.didSetRouteTimelineStickerFrame = false
        setTimelineFrame()
    }

    func configure(with model: RecordEditResourceModel) {
        dataInfo.configure(
            distance: model.distance,
            durationSec: model.durationSec,
            maxElevation: model.maxElevation
        )
        routeSticker.configure(with: model.routes.sorted { $0.sequence < $1.sequence }.map(\.name))
        state.initialBackgroundImageURL = model.mapImageURL
        configureBackgroundImage(with: model.mapImageURL)
    }

    func setBackgroundTapAction(_ action: @escaping () -> Void) {
        recordEditTabBar.onBackgroundTap = action
    }

    func setResetButtonAction(_ action: @escaping () -> Void) {
        resetButton.addAction(UIAction { _ in
            action()
        }, for: .touchUpInside)
    }

    func playLottie(completion: @escaping () -> Void) {
        lottieOverlayView.play(completion: completion)
    }

    func makeEditedImage() -> UIImage {
        recordInfoStickerBox.setCloseButton(isSelected: false)
        routeTimelineStickerBox.setCloseButton(isSelected: false)
        routeStickerBox.setCloseButton(isSelected: false)
        let isResetButtonHidden = resetButton.isHidden
        resetButton.isHidden = true
        layoutIfNeeded()

        let renderFrame = backgroundImageView.frame
        let renderer = UIGraphicsImageRenderer(size: renderFrame.size)

        let editedImage = renderer.image { context in
            context.cgContext.translateBy(
                x: -renderFrame.minX,
                y: -renderFrame.minY
            )
            layer.render(in: context.cgContext)
        }

        resetButton.isHidden = isResetButtonHidden

        return editedImage
    }

    func setGesture() {
        hideOptionViewTapGesture.cancelsTouchesInView = false
        addGestureRecognizer(hideOptionViewTapGesture)
    }

    func setInitialState() {
        deactivateStickerBox(recordInfoStickerBox)
        deactivateStickerBox(routeTimelineStickerBox)
    }

    func resetEditingContent() {
        recordEditTabBar.hideOptionView()
        removeStickerBoxWithoutMarkingChange(routeStickerBox)
        restoreRouteTimelineStickerBox()
        deactivateStickerBox(routeTimelineStickerBox)
        resetBackground()
        resetEditorColor()
        state.hasChanges = false
        updateResetButtonState()
        bringControlsFront()
    }

    // MARK: - Actions

    func setAddTarget() {
        setBrightnessAction()
        setColorAction()
        setOptionViewVisibilityAction()
        setStickerAction()
        setStickerDeleteAction()
    }

    private func setBrightnessAction() {
        recordEditTabBar.onBrightnessChanged = { [weak self] value in
            self?.updateBackgroundBrightness(value)
        }
    }

    private func setColorAction() {
        recordEditTabBar.onColorSelected = { [weak self] color in
            self?.updateEditorColor(color)
        }
    }

    private func setOptionViewVisibilityAction() {
        recordEditTabBar.onOptionViewVisibilityChanged = { [weak self] isVisible in
            self?.resetButton.isHidden = isVisible
        }
    }

    private func setStickerAction() {
        recordEditTabBar.onStickerEditingChanged = { [weak self] isEnabled in
            self?.setStickerEditingEnabled(isEnabled)
        }

        recordEditTabBar.onStickerSelected = { [weak self] stickerType in
            switch stickerType {
            case .record:
                self?.showRecordInfoSticker()
            case .photoTimeline:
                self?.selectTimelineSticker()
            case .route:
                self?.showRouteSticker()
            }
        }
    }

    private func setStickerDeleteAction() {
        routeTimelineStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            removeStickerBox(routeTimelineStickerBox)
        }

        routeStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            removeStickerBox(routeStickerBox)
        }

        recordInfoStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            removeStickerBox(recordInfoStickerBox)
        }

        routeTimelineStickerBox.onMoved = { [weak self] in
            self?.markChanged()
        }

        routeStickerBox.onMoved = { [weak self] in
            self?.markChanged()
        }

        recordInfoStickerBox.onMoved = { [weak self] in
            self?.markChanged()
        }

        [
            recordInfoStickerBox,
            routeTimelineStickerBox,
            routeStickerBox
        ].forEach { stickerBox in
            stickerBox.onSelected = { [weak self, weak stickerBox] in
                guard let self, let stickerBox else { return }

                activateStickerBox(stickerBox)
            }
        }
    }

    @objc
    private func handleViewTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: recordEditTabBar)
        let recordInfoStickerPoint = gesture.location(in: recordInfoStickerBox)
        let routeTimelineStickerPoint = gesture.location(in: routeTimelineStickerBox)
        let routeStickerPoint = gesture.location(in: routeStickerBox)

        guard !recordEditTabBar.containsInteractivePoint(point) else { return }

        if recordInfoStickerBox.superview != nil,
           recordInfoStickerBox.isSelected,
           !recordInfoStickerBox.bounds.contains(recordInfoStickerPoint) {
            deactivateStickerBox(recordInfoStickerBox)
        }

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

    // MARK: - Brightness Update

    private func updateBackgroundBrightness(_ value: CGFloat) {
        setBackgroundOpacity(backgroundOpacity(for: value), marksChange: true)
    }

    private func backgroundOpacity(for value: CGFloat) -> CGFloat {
        let clampedValue = min(max(value, 0), 1)
        let centerValue: CGFloat = 0.5
        let baseOpacity = state.backgroundOpacityBase

        if clampedValue < centerValue {
            let progress = (centerValue - clampedValue) / centerValue
            return baseOpacity + ((1 - baseOpacity) * progress)
        }

        let progress = (clampedValue - centerValue) / centerValue
        return baseOpacity * (1 - progress)
    }

    private func setBackgroundOpacity(_ opacity: CGFloat, marksChange: Bool) {
        let clampedOpacity = min(max(opacity, 0), 1)
        guard state.backgroundOpacity != clampedOpacity else { return }

        state.backgroundOpacity = clampedOpacity
        backgroundOpacityView.backgroundColor = UIColor.staticBlack.withAlphaComponent(clampedOpacity)

        if marksChange {
            markChanged()
        }
    }

    // MARK: - Color Update

    private func updateEditorColor(_ color: UIColor) {
        guard state.selectedColor != color else { return }

        state.selectedColor = color
        dataInfo.updateColor(color)
        routeTimelineDrawingView.updateColor(color)
        routeSticker.updateColor(color)
        markChanged()
    }

    // MARK: - Sticker Editing

    private func setStickerEditingEnabled(_ isEnabled: Bool) {
        if !isEnabled {
            deactivateStickerBox(recordInfoStickerBox)
            deactivateStickerBox(routeTimelineStickerBox)
            deactivateStickerBox(routeStickerBox)
            return
        }

        recordInfoStickerBox.isUserInteractionEnabled = recordInfoStickerBox.superview != nil
        routeTimelineStickerBox.isUserInteractionEnabled = routeTimelineStickerBox.superview != nil
        routeStickerBox.isUserInteractionEnabled = routeStickerBox.superview != nil
    }

    private func showRecordInfoSticker() {
        guard recordInfoStickerBox.superview == nil else {
            activateStickerBox(recordInfoStickerBox)
            return
        }

        addSubview(recordInfoStickerBox)
        recordInfoStickerBox.frame = defaultRecordInfoStickerFrame()
        state.didSetRecordInfoStickerFrame = true
        markChanged()
        activateStickerBox(recordInfoStickerBox)
    }

    private func selectTimelineSticker() {
        if routeTimelineStickerBox.superview == nil {
            addSubview(routeTimelineStickerBox)
            updateTimelineFrame()
            markChanged()
        }

        activateStickerBox(routeTimelineStickerBox)
    }

    private func showRouteSticker() {
        guard routeStickerBox.superview == nil else {
            activateStickerBox(routeStickerBox)
            return
        }

        addSubview(routeStickerBox)
        markChanged()
        layoutIfNeeded()
        routeSticker.updateColor(state.selectedColor)

        let stickerSize = stickerBoxSize(for: routeStickerBox)
        let dataInfoFrame = recordInfoFrameForRouteAnchor()

        routeStickerBox.frame = CGRect(
            x: dataInfoFrame.minX - 8,
            y: dataInfoFrame.maxY + 11,
            width: stickerSize.width,
            height: stickerSize.height
        )

        activateStickerBox(routeStickerBox)
    }

    // MARK: - Sticker Layout

    private func updateMoveBounds() {
        let movementBounds = backgroundImageView.frame.insetBy(
            dx: stickerMovementInset,
            dy: stickerMovementInset
        )

        recordInfoStickerBox.movementBounds = movementBounds
        routeTimelineStickerBox.movementBounds = movementBounds
        routeStickerBox.movementBounds = movementBounds
    }

    private func setRecordInfoFrame() {
        guard !state.didSetRecordInfoStickerFrame,
              backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        recordInfoStickerBox.frame = defaultRecordInfoStickerFrame()
        state.didSetRecordInfoStickerFrame = true
    }

    private func defaultRecordInfoStickerFrame() -> CGRect {
        CGRect(
            x: backgroundImageView.frame.minX + 32 - recordInfoStickerInsets.left,
            y: backgroundImageView.frame.minY + 80 - recordInfoStickerInsets.top,
            width: recordInfoContentSize.width + recordInfoStickerInsets.left + recordInfoStickerInsets.right,
            height: recordInfoContentSize.height + recordInfoStickerInsets.top + recordInfoStickerInsets.bottom
        )
    }

    private func recordInfoFrameForRouteAnchor() -> CGRect {
        guard dataInfo.window != nil else {
            let stickerFrame = defaultRecordInfoStickerFrame()

            return CGRect(
                x: stickerFrame.minX + recordInfoStickerInsets.left,
                y: stickerFrame.minY + recordInfoStickerInsets.top,
                width: recordInfoContentSize.width,
                height: recordInfoContentSize.height
            )
        }

        return dataInfo.convert(dataInfo.bounds, to: self)
    }

    private func setTimelineFrame() {
        guard !state.didSetRouteTimelineStickerFrame,
              backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        updateTimelineFrame()
        state.didSetRouteTimelineStickerFrame = true
    }

    private func updateTimelineFrame() {
        guard backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        let routePoints = state.trackPoints.toCanvasPoints(in: backgroundImageView.bounds.size)

        let markers = state.timelineMarkers.compactMap { marker -> RouteTimelineMarker? in
            guard let point = state.trackPoints.toCanvasPoint(
                latitude: marker.latitude,
                longitude: marker.longitude,
                in: backgroundImageView.bounds.size
            ) else {
                return nil
            }

            return RouteTimelineMarker(
                thumbnailUrl: marker.thumbnailUrl,
                point: point
            )
        }

        guard let routeRect = routeTimelineDrawingView.configureSticker(
            points: routePoints,
            markers: markers
        ) else {
            return
        }

        let stickerHeight = routeRect.height + timelineStickerInsets.top + timelineStickerInsets.bottom
        let stickerWidth = routeRect.width + timelineStickerInsets.left + timelineStickerInsets.right
        let targetFrame = CGRect(
            x: backgroundImageView.frame.minX + routeRect.minX - timelineStickerInsets.left,
            y: backgroundImageView.frame.maxY - stickerHeight - timelineStickerBottomOffset,
            width: stickerWidth,
            height: stickerHeight
        )

        routeTimelineDrawingView.updateColor(state.selectedColor)
        routeTimelineStickerBox.frame = clampedStickerFrame(targetFrame)
    }

    // MARK: - Sticker Helpers

    private func activateStickerBox(_ stickerBox: StickerBox) {
        deactivateStickerBoxes(except: stickerBox)
        stickerBox.isUserInteractionEnabled = true
        stickerBox.setCloseButton(isSelected: true)
        bringSubviewToFront(stickerBox)
        bringControlsFront()
    }

    private func deactivateStickerBoxes(except selectedStickerBox: StickerBox) {
        [
            recordInfoStickerBox,
            routeTimelineStickerBox,
            routeStickerBox
        ]
        .filter { $0 !== selectedStickerBox }
        .forEach(deactivateStickerBox)
    }

    private func deactivateStickerBox(_ stickerBox: StickerBox) {
        stickerBox.setCloseButton(isSelected: false)
        stickerBox.isUserInteractionEnabled = false
    }

    private func removeStickerBox(_ stickerBox: StickerBox) {
        guard stickerBox.superview != nil else { return }

        stickerBox.removeFromSuperview()
        markChanged()
    }

    private func removeStickerBoxWithoutMarkingChange(_ stickerBox: StickerBox) {
        guard stickerBox.superview != nil else { return }

        stickerBox.removeFromSuperview()
    }

    private func restoreRouteTimelineStickerBox() {
        if routeTimelineStickerBox.superview == nil {
            insertSubview(routeTimelineStickerBox, belowSubview: recordInfoStickerBox)
        }

        layoutIfNeeded()
        updateTimelineFrame()
    }

    private func bringControlsFront() {
        bringSubviewToFront(topNavigationBar)
        bringSubviewToFront(recordEditTabBar)
        bringSubviewToFront(resetButton)
    }

    private func stickerBoxSize(for stickerBox: StickerBox) -> CGSize {
        stickerBox.setNeedsLayout()
        stickerBox.layoutIfNeeded()

        return stickerBox.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    private func clampedStickerFrame(_ frame: CGRect) -> CGRect {
        let movementBounds = backgroundImageView.frame.insetBy(
            dx: stickerMovementInset,
            dy: stickerMovementInset
        )
        let maxX = movementBounds.maxX - frame.width
        let maxY = movementBounds.maxY - frame.height

        return CGRect(
            x: maxX < movementBounds.minX
                ? movementBounds.minX
                : min(max(frame.minX, movementBounds.minX), maxX),
            y: maxY < movementBounds.minY
                ? movementBounds.minY
                : min(max(frame.minY, movementBounds.minY), maxY),
            width: frame.width,
            height: frame.height
        )
    }

    private func configureBackgroundImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else {
            backgroundImageView.image = .imgNavermapMain
            return
        }

        backgroundImageView.kf.setImage(
            with: url,
            placeholder: UIImage.imgNavermapMain
        )
    }

    private func resetBackground() {
        configureBackgroundImage(with: state.initialBackgroundImageURL)
        state.backgroundOpacityBase = 0.5
        setBackgroundOpacity(state.backgroundOpacityBase, marksChange: false)
        recordEditTabBar.setBrightnessValue(0.5)
    }

    private func resetEditorColor() {
        state.selectedColor = .recapMint
        dataInfo.updateColor(state.selectedColor)
        routeTimelineDrawingView.updateColor(state.selectedColor)
        routeSticker.updateColor(state.selectedColor)
    }

    private func markChanged() {
        guard !state.hasChanges else { return }

        state.hasChanges = true
        updateResetButtonState()
    }

    private func updateResetButtonState() {
        resetButton.isEnabled = state.hasChanges
    }

}
