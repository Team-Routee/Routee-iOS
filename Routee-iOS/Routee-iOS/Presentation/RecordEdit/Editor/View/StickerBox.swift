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
    
    // MARK: - Property
    
    var onDeleted: (() -> Void)?
    var isSelected: Bool {
        !borderView.isHidden
    }
    
    // MARK: - UI Properties
    
    private let contentView: UIView
    private let borderView = UIView()
    private let closeButton = UIButton()
    
    // MARK: - Init
    
    init(contentView: UIView) {
        self.contentView = contentView
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
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.statusInfo.cgColor
        }
        
        closeButton.do {
            $0.setImage(UIImage(named: "ic_delete_image"), for: .normal)
            $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        }
    }
    
    override func setUI() {
        addSubviews(contentView, borderView, closeButton)
    }
    
    override func setLayout() {
        contentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(13)
            $0.verticalEdges.equalToSuperview().inset(10)
        }
        
        borderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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

        center = CGPoint(
            x: center.x + translation.x,
            y: center.y + translation.y
        )

        gesture.setTranslation(.zero, in: superview)
    }
    
    @objc
    private func closeButtonTapped() {
        onDeleted?()
    }
}
