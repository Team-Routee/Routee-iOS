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

    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    let topNavigationBar = TopNavigationBar(rightTitle: "완료")
    private let backgroundOpacityView = UIView()
    private let backgroundImageView = UIImageView()
    private let dataInfo = RecordInfo()
    private let recordEditTabBar = RecordEditTabBar()
    private lazy var hideOptionViewTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleViewTapped(_:))
    )

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary
        hideOptionViewTapGesture.cancelsTouchesInView = false
        
        backgroundOpacityView.do {
            $0.backgroundColor = .black40
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
            dataInfo,
            topNavigationBar,
            recordEditTabBar
        )

        addGestureRecognizer(hideOptionViewTapGesture)
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
    }
    
    // MARK: - Public Methods
    
    // 선택한 이미지를 배경 이미지뷰에 적용합니다.
    func updateBackgroundImage(_ image: UIImage) {
        backgroundImageView.image = image
    }
    
    // 하단 탭바의 배경 변경 액션을 외부에서 연결합니다.
    func setBackgroundTapAction(_ action: @escaping () -> Void) {
        recordEditTabBar.onBackgroundTap = action
    }

    // MARK: - Actions

    @objc
    private func handleViewTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: recordEditTabBar)

        guard !recordEditTabBar.containsInteractivePoint(point) else { return }

        recordEditTabBar.hideOptionView()
    }
}
