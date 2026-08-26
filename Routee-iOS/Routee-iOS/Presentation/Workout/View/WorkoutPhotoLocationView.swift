//
//  WorkoutPhotoLocationView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/12/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutPhotoLocationView: BaseUIView {
    
    // MARK: - UI Properties
    
    let topNavigationBar = TopNavigationBar()
    let locationTextField = RouteeTextField(
        placeholder: "현재 위치를 남겨주세요.",
        icon: .icLocationInfoSmMint
    )
    let completeButton = RouteeButton(titleText: "기록 완료", type: .enabled)

    private let contentClippingView = UIView()
    private let contentContainerView = UIView()
    private let photoImageView = UIImageView()
    private let textLengthLabel = UILabel()
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        photoImageView.image = image
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(contentClippingView, topNavigationBar, completeButton)

        contentClippingView.addSubview(contentContainerView)

        contentContainerView.addSubviews(
            photoImageView,
            locationTextField,
            textLengthLabel
        )
    }
    
    override func setStyle() {
        backgroundColor = .bgPrimary

        contentClippingView.clipsToBounds = true

        photoImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        
        locationTextField.returnKeyType = .done

        textLengthLabel.do {
            $0.text = "0/16"
            $0.textColor = .white30
            $0.font = .label_m_14
        }
    }
    
    override func setLayout() {
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        contentClippingView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        contentContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        photoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(468)
        }
        
        locationTextField.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        textLengthLabel.snp.makeConstraints {
            $0.top.equalTo(locationTextField.snp.bottom).offset(12)
            $0.trailing.equalTo(locationTextField.snp.trailing)
        }

        completeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(locationTextField.snp.bottom).offset(36)
        }
    }
    
    // MARK: - Public Method
    
    func updateTextLength(_ length: Int) {
        textLengthLabel.text = "\(length)/16"
    }
    
    func moveContent(toKeyboardTop keyboardTop: CGFloat) {
        contentContainerView.transform = .identity
        layoutIfNeeded()
        
        let labelFrame = textLengthLabel.convert(textLengthLabel.bounds, to: self)
        let translationY = keyboardTop - labelFrame.maxY
        contentContainerView.transform = CGAffineTransform(translationX: 0, y: min(0, translationY))
    }
    
    func resetContentPosition() {
        contentContainerView.transform = .identity
    }
}
