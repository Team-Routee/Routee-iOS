//
//  ErrorView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import UIKit

import SnapKit
import Then

enum ErrorCase {
    case notFound
    case unknown
    
    var image: UIImage {
        switch self {
        case .notFound:
                .graphic404ErrorXl
        case .unknown:
                .graphicUnknowErrorXl
        }
    }
    
    var title: String {
        switch self {
        case .notFound:
            "페이지를 찾을 수 없어요"
        case .unknown:
            "알 수 없는 오류가 발생했어요"
        }
    }
    
    var subtitle: String {
        switch self {
        case .notFound:
            "요청하신 페이지가 존재하지 않거나\n이동되었을 수 있어요."
        case .unknown:
            "예상치 못한 문제가 발생했어요.\n잠시 후 다시 시도해주세요."
        }
    }
}

final class ErrorView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    private let errorImageView = UIImageView()
    private let errorLabel = UILabel()
    private let errorSubLabel = UILabel()
    let toHomeButton = UIButton(type: .custom)
    let retryButton = UIButton(type: .custom)
    
    // MARK: - Properties
    
    private let errorCase: ErrorCase
    
    // MARK: - Initializer
    
    init(errorCase: ErrorCase) {
        self.errorCase = errorCase
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        errorImageView.do {
            $0.image = errorCase.image
            $0.contentMode = .scaleAspectFit
        }
        
        errorLabel.do {
            $0.text = errorCase.title
            $0.font = .label_m_16
            $0.textColor = .staticWhite
        }
        
        errorSubLabel.do {
            $0.text = errorCase.subtitle
            $0.numberOfLines = 2
            $0.font = .label_r_12
            $0.textColor = .grey_200
            $0.textAlignment = .center
        }
        
        configureRetryButton()
        configureToHomeButton()
        retryButton.isHidden = errorCase == .notFound
    }
    
    override func setUI() {
        addSubviews(
            backgroundGradientView,
            errorImageView,
            errorLabel,
            errorSubLabel,
            toHomeButton,
            retryButton
        )
    }
    
    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        errorImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide).inset(232)
            $0.height.equalTo(72)
        }
        
        errorLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(errorImageView.snp.bottom).offset(24)
            $0.height.equalTo(22)
        }
        
        errorSubLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(errorLabel.snp.bottom).offset(10)
            $0.height.equalTo(34)
        }
        
        switch errorCase {
        case .notFound:
            toHomeButton.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(errorSubLabel.snp.bottom).offset(80)
                $0.width.equalTo(240)
                $0.height.equalTo(54)
            }
            
        case .unknown:
            retryButton.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(errorSubLabel.snp.bottom).offset(80)
                $0.width.equalTo(240)
                $0.height.equalTo(54)
            }
            
            toHomeButton.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(retryButton.snp.bottom).offset(16)
                $0.width.equalTo(240)
                $0.height.equalTo(54)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func configureRetryButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .icRetry
        configuration.imagePadding = 8
        configuration.baseForegroundColor = .mint500
        configuration.attributedTitle = AttributedString(
            "다시 시도",
            attributes: AttributeContainer([.font: UIFont.label_sb_16])
        )
        
        retryButton.configuration = configuration
        retryButton.tintColor = .mint500
        retryButton.backgroundColor = .bg_cta_secondary
        retryButton.layer.borderWidth = 1
        retryButton.layer.borderColor = UIColor.mint300.cgColor
        retryButton.layer.cornerRadius = 28
        retryButton.configurationUpdateHandler = { button in
            UIView.performWithoutAnimation {
                button.configuration = configuration
            }
        }
    }
    
    private func configureToHomeButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = errorCase == .notFound ? .mint500 : .grey200
        configuration.attributedTitle = AttributedString(
            "홈으로 이동",
            attributes: AttributeContainer([.font: UIFont.label_sb_16])
        )
        
        toHomeButton.configuration = configuration
        toHomeButton.tintColor = errorCase == .notFound ? .mint500 : .grey200
        toHomeButton.backgroundColor = errorCase == .notFound ? .bg_cta_secondary : .clear
        toHomeButton.layer.borderWidth = 1
        toHomeButton.layer.borderColor = errorCase == .notFound
        ? UIColor.mint300.cgColor
        : UIColor.staticWhite.cgColor
        toHomeButton.layer.cornerRadius = 28
        toHomeButton.configurationUpdateHandler = { button in
            UIView.performWithoutAnimation {
                button.configuration = configuration
            }
        }
    }
}
