//
//  EditorView+Sticker.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import UIKit

extension EditorView {

    // MARK: - UI Setting

    func setStickerAction() {
        recordEditTabBar.onStickerEditingChanged = { [weak self] isEnabled in
            self?.setStickerEditingEnabled(isEnabled)
        }

        recordEditTabBar.onStickerSelected = { [weak self] stickerType in
            switch stickerType {
            case .photoTimeline:
                self?.selectTimelineSticker()
            case .route:
                self?.showRouteSticker()
            }
        }
    }

    func setStickerDeleteAction() {
        routeTimelineStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            removeStickerBox(routeTimelineStickerBox)
        }

        routeStickerBox.onDeleted = { [weak self] in
            guard let self else { return }

            removeStickerBox(routeStickerBox)
        }
    }

    // MARK: - Private Methods

    func setStickerEditingEnabled(_ isEnabled: Bool) {
        if !isEnabled {
            deactivateStickerBox(routeTimelineStickerBox)
            deactivateStickerBox(routeStickerBox)
            return
        }

        routeTimelineStickerBox.isUserInteractionEnabled = routeTimelineStickerBox.superview != nil
        routeStickerBox.isUserInteractionEnabled = routeStickerBox.superview != nil
    }

    func selectTimelineSticker() {
        removeStickerBox(routeStickerBox)

        if routeTimelineStickerBox.superview == nil {
            addSubview(routeTimelineStickerBox)
            updateTimelineFrame()
        }

        activateStickerBox(routeTimelineStickerBox)
    }

    func showRouteSticker() {
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

        activateStickerBox(routeStickerBox)
    }

    func updateMoveBounds() {
        let movementBounds = backgroundImageView.frame.insetBy(
            dx: stickerMovementInset,
            dy: stickerMovementInset
        )

        routeTimelineStickerBox.movementBounds = movementBounds
        routeStickerBox.movementBounds = movementBounds
    }

    func setTimelineFrame() {
        guard !state.didSetRouteTimelineStickerFrame,
              backgroundImageView.bounds.width > 0,
              backgroundImageView.bounds.height > 0
        else {
            return
        }

        updateTimelineFrame()
        state.didSetRouteTimelineStickerFrame = true
    }

    func updateTimelineFrame() {
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

    func activateStickerBox(_ stickerBox: StickerBox) {
        stickerBox.isUserInteractionEnabled = true
        stickerBox.setCloseButton(isSelected: true)
        bringSubviewToFront(stickerBox)
        bringControlsFront()
    }

    func deactivateStickerBox(_ stickerBox: StickerBox) {
        stickerBox.setCloseButton(isSelected: false)
        stickerBox.isUserInteractionEnabled = false
    }

    func removeStickerBox(_ stickerBox: StickerBox) {
        stickerBox.removeFromSuperview()
    }

    func bringControlsFront() {
        bringSubviewToFront(topNavigationBar)
        bringSubviewToFront(recordEditTabBar)
    }

    func stickerBoxSize(for stickerBox: StickerBox) -> CGSize {
        stickerBox.setNeedsLayout()
        stickerBox.layoutIfNeeded()

        return stickerBox.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    // MARK: - Actions

    @objc
    func handleViewTapped(_ gesture: UITapGestureRecognizer) {
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
