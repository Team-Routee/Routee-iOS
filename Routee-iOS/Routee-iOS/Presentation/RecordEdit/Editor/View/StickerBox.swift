//
//  StickerBoxView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class StickerBox: BaseUIView {

    // MARK: - Properties

    var onDeleted: (() -> Void)?
    var onMoved: (() -> Void)?
    var isSelected: Bool {
        !borderView.isHidden
    }
    private let resizeHitArea: CGFloat = 8
    private let minimumVisibleLength: CGFloat = 20
    private let minimumScale: CGFloat = 0.01
    private var activeResizeEdges: UIRectEdge = []
    private var initialPanFrame: CGRect = .zero
    private var baseStickerSize: CGSize = .zero
    private var baseContentSize: CGSize = .zero
    private var contentScale: CGFloat = 1

    // MARK: - UI Properties

    private let contentView: UIView
    private let contentInsets: UIEdgeInsets
    private let contentContainerView = UIView()
    private let borderView = UIView()
    private let topLeadingHandleView = UIView()
    private let bottomLeadingHandleView = UIView()
    private let bottomTrailingHandleView = UIView()
    private let closeButton = UIButton()

    // MARK: - Init

    init(
        contentView: UIView,
        contentInsets: UIEdgeInsets
    ) {
        self.contentView = contentView
        self.contentInsets = contentInsets
        super.init(frame: .zero)

        setGesture()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .clear
        contentContainerView.clipsToBounds = true

        borderView.do {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.statusInfo.cgColor
        }

        [
            topLeadingHandleView,
            bottomLeadingHandleView,
            bottomTrailingHandleView
        ].forEach {
            $0.backgroundColor = .staticWhite
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.statusInfo.cgColor
        }

        closeButton.do {
            $0.setImage(UIImage(named: "ic_delete_image"), for: .normal)
            $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }
    }

    override func setUI() {
        addSubviews(
            contentContainerView,
            borderView,
            topLeadingHandleView,
            bottomLeadingHandleView,
            bottomTrailingHandleView,
            closeButton
        )

        contentContainerView.addSubview(contentView)
    }

    override func setLayout() {
        borderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        topLeadingHandleView.snp.makeConstraints {
            $0.centerX.equalTo(borderView.snp.leading)
            $0.centerY.equalTo(borderView.snp.top)
            $0.size.equalTo(8)
        }

        bottomLeadingHandleView.snp.makeConstraints {
            $0.centerX.equalTo(borderView.snp.leading)
            $0.centerY.equalTo(borderView.snp.bottom)
            $0.size.equalTo(8)
        }

        bottomTrailingHandleView.snp.makeConstraints {
            $0.centerX.equalTo(borderView.snp.trailing)
            $0.centerY.equalTo(borderView.snp.bottom)
            $0.size.equalTo(8)
        }

        closeButton.snp.makeConstraints {
            $0.centerX.equalTo(borderView.snp.trailing)
            $0.centerY.equalTo(borderView.snp.top)
            $0.size.equalTo(24)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setBaseSizeIfNeeded()
        layoutContentView()
    }

    // MARK: - Public Methods

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if bounds.contains(point) {
            return true
        }

        let handleViews = [
            topLeadingHandleView,
            bottomLeadingHandleView,
            bottomTrailingHandleView,
            closeButton
        ]

        return handleViews.contains {
            !$0.isHidden && $0.frame.insetBy(dx: -8, dy: -8).contains(point)
        }
    }

    func setCloseButton(isSelected: Bool) {
        borderView.isHidden = !isSelected
        [
            topLeadingHandleView,
            bottomLeadingHandleView,
            bottomTrailingHandleView
        ].forEach {
            $0.isHidden = !isSelected
        }
        closeButton.isHidden = !isSelected
    }

    func resetContentLayoutScale() {
        baseStickerSize = .zero
        baseContentSize = .zero
        contentScale = 1
        activeResizeEdges = []
        setNeedsLayout()
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        let contentSize = contentView.systemLayoutSizeFitting(targetSize)

        return CGSize(
            width: contentSize.width + contentInsets.left + contentInsets.right,
            height: contentSize.height + contentInsets.top + contentInsets.bottom
        )
    }

    // MARK: - Actions

    private func setGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPanned(_:)))

        addGestureRecognizer(panGesture)
    }

    @objc
    private func handleStickerPanned(_ gesture: UIPanGestureRecognizer) {
        guard isSelected, let superview else { return }

        if gesture.state == .began {
            setBaseSizeIfNeeded()
            activeResizeEdges = resizeEdges(for: gesture.location(in: self))
            initialPanFrame = frame
        }

        let translation = gesture.translation(in: superview)
        guard translation != .zero else { return }

        if activeResizeEdges.isEmpty {
            frame = clampedVisibleFrame(frame.offsetBy(dx: translation.x, dy: translation.y))
            gesture.setTranslation(.zero, in: superview)
        } else {
            resize(with: translation)
        }

        onMoved?()

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            activeResizeEdges = []
        }
    }

    @objc
    private func closeButtonTapped() {
        onDeleted?()
    }

    private func resizeEdges(for point: CGPoint) -> UIRectEdge {
        var edges: UIRectEdge = []

        if point.x <= resizeHitArea {
            edges.insert(.left)
        } else if point.x >= bounds.width - resizeHitArea {
            edges.insert(.right)
        }

        if point.y <= resizeHitArea {
            edges.insert(.top)
        } else if point.y >= bounds.height - resizeHitArea {
            edges.insert(.bottom)
        }

        return edges
    }

    private func resize(with translation: CGPoint) {
        guard baseStickerSize.width > 0 else { return }

        var targetWidth = initialPanFrame.width
        var targetHeight = initialPanFrame.height

        if activeResizeEdges.contains(.left) {
            targetWidth -= translation.x
        } else if activeResizeEdges.contains(.right) {
            targetWidth += translation.x
        }

        if activeResizeEdges.contains(.top) {
            targetHeight -= translation.y
        } else if activeResizeEdges.contains(.bottom) {
            targetHeight += translation.y
        }

        let widthScale = targetWidth / initialPanFrame.width
        let heightScale = targetHeight / initialPanFrame.height
        let isHorizontalResize = activeResizeEdges.contains(.left) || activeResizeEdges.contains(.right)
        let isVerticalResize = activeResizeEdges.contains(.top) || activeResizeEdges.contains(.bottom)

        let targetScale = scale(
            widthScale: widthScale,
            heightScale: heightScale,
            isHorizontalResize: isHorizontalResize,
            isVerticalResize: isVerticalResize
        )
        let resizedFrame = resizedFrame(scale: targetScale)

        frame = clampedVisibleFrame(resizedFrame)
        contentScale = frame.width / baseStickerSize.width
        layoutIfNeeded()
    }

    private func scale(
        widthScale: CGFloat,
        heightScale: CGFloat,
        isHorizontalResize: Bool,
        isVerticalResize: Bool
    ) -> CGFloat {
        let candidateScale: CGFloat

        if isHorizontalResize && isVerticalResize {
            candidateScale = abs(widthScale - 1) > abs(heightScale - 1) ? widthScale : heightScale
        } else if isHorizontalResize {
            candidateScale = widthScale
        } else {
            candidateScale = heightScale
        }

        return max(candidateScale, minimumScale)
    }

    private func resizedFrame(scale: CGFloat) -> CGRect {
        let resizedSize = CGSize(
            width: initialPanFrame.width * scale,
            height: initialPanFrame.height * scale
        )
        let originX: CGFloat
        let originY: CGFloat

        if activeResizeEdges.contains(.left) {
            originX = initialPanFrame.maxX - resizedSize.width
        } else {
            originX = initialPanFrame.minX
        }

        if activeResizeEdges.contains(.top) {
            originY = initialPanFrame.maxY - resizedSize.height
        } else {
            originY = initialPanFrame.minY
        }

        return CGRect(origin: CGPoint(x: originX, y: originY), size: resizedSize)
    }

    private func setBaseSizeIfNeeded() {
        guard baseStickerSize == .zero,
              bounds.width > 0,
              bounds.height > 0
        else {
            return
        }

        baseStickerSize = bounds.size
        baseContentSize = CGSize(
            width: bounds.width - contentInsets.left - contentInsets.right,
            height: bounds.height - contentInsets.top - contentInsets.bottom
        )
    }

    private func layoutContentView() {
        contentContainerView.frame = bounds.inset(by: scaledContentInsets())

        guard baseContentSize != .zero else {
            contentView.frame = contentContainerView.bounds
            return
        }

        contentView.transform = .identity
        contentView.bounds = CGRect(origin: .zero, size: baseContentSize)
        contentView.center = CGPoint(
            x: contentContainerView.bounds.midX,
            y: contentContainerView.bounds.midY
        )
        contentView.transform = CGAffineTransform(scaleX: contentScale, y: contentScale)
    }

    private func scaledContentInsets() -> UIEdgeInsets {
        UIEdgeInsets(
            top: contentInsets.top * contentScale,
            left: contentInsets.left * contentScale,
            bottom: contentInsets.bottom * contentScale,
            right: contentInsets.right * contentScale
        )
    }

    private func clampedVisibleFrame(_ frame: CGRect) -> CGRect {
        guard let superview else { return frame }

        var clampedFrame = frame
        let bounds = superview.bounds
        let minX = bounds.minX - frame.width + minimumVisibleLength
        let maxX = bounds.maxX - minimumVisibleLength
        let minY = bounds.minY - frame.height + minimumVisibleLength
        let maxY = bounds.maxY - minimumVisibleLength

        clampedFrame.origin.x = min(max(frame.minX, minX), maxX)
        clampedFrame.origin.y = min(max(frame.minY, minY), maxY)

        return clampedFrame
    }
}
