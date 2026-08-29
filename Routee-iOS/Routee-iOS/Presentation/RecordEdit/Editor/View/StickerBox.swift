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
    private let resizeHitArea: CGFloat = 24
    private let minimumScale: CGFloat = 0.01
    private var activeResizeEdges: UIRectEdge = []
    private var initialPanFrame: CGRect = .zero

    // MARK: - UI Properties

    private let contentView: UIView
    private let contentInsets: UIEdgeInsets
    private let borderView = UIView()
    private let topLeadingHandleView = UIView()
    private let bottomLeadingHandleView = UIView()
    private let bottomTrailingHandleView = UIView()
    private let closeButton = UIButton()

    // MARK: - Init

    init(
        contentView: UIView,
        contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
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
            contentView,
            borderView,
            topLeadingHandleView,
            bottomLeadingHandleView,
            bottomTrailingHandleView,
            closeButton
        )
    }

    override func setLayout() {
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(contentInsets.top)
            $0.leading.equalToSuperview().inset(contentInsets.left)
            $0.trailing.equalToSuperview().inset(contentInsets.right)
            $0.bottom.equalToSuperview().inset(contentInsets.bottom)
        }

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

    // MARK: - Actions

    private func setGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPanned(_:)))

        addGestureRecognizer(panGesture)
    }

    @objc
    private func handleStickerPanned(_ gesture: UIPanGestureRecognizer) {
        guard isSelected, let superview else { return }

        if gesture.state == .began {
            activeResizeEdges = resizeEdges(for: gesture.location(in: self))
            initialPanFrame = frame
        }

        let translation = gesture.translation(in: superview)
        guard translation != .zero else { return }

        if activeResizeEdges.isEmpty {
            center = CGPoint(
                x: center.x + translation.x,
                y: center.y + translation.y
            )
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

        transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        center = CGPoint(x: resizedFrame.midX, y: resizedFrame.midY)
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
}
