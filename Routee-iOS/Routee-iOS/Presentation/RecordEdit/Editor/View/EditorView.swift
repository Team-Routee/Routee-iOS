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

    // MARK: - Properties

    let stickerHorizontalInset: CGFloat = 13
    let stickerVerticalInset: CGFloat = 10
    let stickerMovementInset: CGFloat = 12
    var state = EditorState()

    struct EditorState {
        var selectedColor: UIColor = .recapMint
        var didSetRouteTimelineStickerFrame = false
    }

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    let topNavigationBar = TopNavigationBar(rightTitle: "완료")
    private let backgroundOpacityView = UIView()
    let backgroundImageView = UIImageView()
    let routeTimelineDrawingView = RouteDrawer()
    let routeSticker = RouteSticker()
    let dataInfo = RecordInfo()
    let recordEditTabBar = RecordEditTabBar()
    private let lottieOverlayView = LottieOverlayView()
    lazy var routeTimelineStickerBox = StickerBox(contentView: routeTimelineDrawingView)
    lazy var routeStickerBox = StickerBox(contentView: routeSticker)
    private lazy var hideOptionViewTapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleViewTapped(_:))
    )

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setGesture()
        setAction()
        setInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary

        backgroundOpacityView.do {
            $0.backgroundColor = .black50
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
            routeTimelineStickerBox,
            dataInfo,
            topNavigationBar,
            recordEditTabBar,
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

        lottieOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMoveBounds()
        setTimelineFrame()
    }

    // MARK: - Public Methods

    func updateBackgroundImage(_ image: UIImage) {
        backgroundImageView.image = image
        backgroundOpacityView.backgroundColor = .black40
    }

    func setBackgroundTapAction(_ action: @escaping () -> Void) {
        recordEditTabBar.onBackgroundTap = action
    }

    func playLottie(completion: @escaping () -> Void) {
        lottieOverlayView.play(completion: completion)
    }

    // MARK: - Private Methods

    private func setGesture() {
        hideOptionViewTapGesture.cancelsTouchesInView = false
        addGestureRecognizer(hideOptionViewTapGesture)
    }

    private func setAction() {
        setColorAction()
        setStickerAction()
        setStickerDeleteAction()
    }

    private func setInitialState() {
        deactivateStickerBox(routeTimelineStickerBox)
    }
}
