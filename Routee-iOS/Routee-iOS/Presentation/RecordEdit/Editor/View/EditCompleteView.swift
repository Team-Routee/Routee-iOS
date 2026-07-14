//
//  EditCompleteView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class EditCompleteView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    let topNavigationBar = TopNavigationBar(rightTitle: "완료")
    private let backgroundImageView = UIImageView()
    private let buttonStackView = UIStackView()
    private let downloadButton = UIButton()
    private let exportButton = UIButton()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary
        
        backgroundImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 20
        }
        
        downloadButton.do {
            $0.backgroundColor = .mint300
            $0.layer.cornerRadius = 30
            $0.setImage(UIImage(named: "ic_download_recap_lg"), for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
        }
        
        exportButton.do {
            $0.backgroundColor = .mint300
            $0.layer.cornerRadius = 30
            $0.setImage(UIImage(named: "ic_share_recap_lg"), for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    override func setUI() {
        addSubviews(
            backgroundGradientView,
            topNavigationBar,
            backgroundImageView,
            buttonStackView
        )
        
        buttonStackView.addArrangedSubviews(downloadButton, exportButton)
    }
    
    override func setLayout() {
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(35)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(125)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(backgroundImageView.snp.bottom).offset(35)
            $0.centerX.equalToSuperview()
        }
        
        downloadButton.snp.makeConstraints {
            $0.size.equalTo(60)
        }
        
        exportButton.snp.makeConstraints {
            $0.size.equalTo(60)
        }
    }
    
    // MARK: - Public Methods
    
    func updateImage(_ image: UIImage) {
        backgroundImageView.image = image
    }
    
    func showToast(title: String) {
        subviews
            .filter { $0 is ToastMessageView }
            .forEach { $0.removeFromSuperview() }
        
        let toastMessageView = ToastMessageView(title: title)
        
        addSubview(toastMessageView)
        layoutIfNeeded()
        
        let toastWidth = min(
            toastMessageView.titleLabel.intrinsicContentSize.width + 32,
            bounds.width - 48
        )
        
        toastMessageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(backgroundImageView.snp.bottom).offset(-15)
            $0.width.equalTo(toastWidth)
            $0.height.equalTo(37)
        }
        
        toastMessageView.layer.cornerRadius = 12
        toastMessageView.clipsToBounds = true
        
        UIView.animate(withDuration: 1.5) {
            toastMessageView.alpha = 0
        } completion: { _ in
            toastMessageView.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    
    func setDownloadButtonAction(_ action: @escaping () -> Void) {
        downloadButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }

    func setExportButtonAction(_ action: @escaping () -> Void) {
        exportButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }
}
