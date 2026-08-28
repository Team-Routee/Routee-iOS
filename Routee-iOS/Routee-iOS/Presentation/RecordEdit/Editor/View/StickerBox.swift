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
    var movementBounds: CGRect?
    var isSelected: Bool {
        !borderView.isHidden
    }

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

        return !closeButton.isHidden
        && closeButton.frame.insetBy(dx: -8, dy: -8).contains(point)
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStickerTapped))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStickerPanned(_:)))

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
    }

    @objc
    private func handleStickerTapped() {
        setCloseButton(isSelected: true)
    }

    @objc
    private func handleStickerPanned(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }

        let translation = gesture.translation(in: superview)
        guard translation != .zero else { return }

        let movedFrame = frame.offsetBy(dx: translation.x, dy: translation.y)
        let updatedFrame = clampedFrame(movedFrame)
        guard frame != updatedFrame else {
            gesture.setTranslation(.zero, in: superview)
            return
        }

        frame = updatedFrame
        onMoved?()

        gesture.setTranslation(.zero, in: superview)
    }

    private func clampedFrame(_ frame: CGRect) -> CGRect {
        guard let movementBounds else { return frame }

        let maxX = movementBounds.maxX - frame.width
        let maxY = movementBounds.maxY - frame.height

        return CGRect(
            x: min(max(frame.minX, movementBounds.minX), maxX),
            y: min(max(frame.minY, movementBounds.minY), maxY),
            width: frame.width,
            height: frame.height
        )
    }

    @objc
    private func closeButtonTapped() {
        onDeleted?()
    }
}
