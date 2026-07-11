//
//  TimeLineCard.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import SnapKit
import Then

final class TimeLineCard: BaseUIView {
    private let imageScrollView = UIScrollView()
    private let imageStackView = UIStackView()
    private let pageControl = UIPageControl()

    private var imageViews: [UIImageView] = []
    private var imageCount = 0
    
    init(imageNames: [String]) {
        imageViews = imageNames.map { imageName in
            let imageView = UIImageView()
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }
        imageCount = imageNames.count

        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyle() {
        imageScrollView.do {
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.bounces = true
            $0.delegate = self
        }

        imageStackView.do {
            $0.axis = .horizontal
            $0.spacing = 0
        }

        pageControl.do {
            $0.numberOfPages = min(imageCount, 5)
            $0.currentPage = 0
            $0.hidesForSinglePage = false
            $0.isUserInteractionEnabled = false
            $0.pageIndicatorTintColor = .grey400
            $0.currentPageIndicatorTintColor = .staticWhite
            $0.preferredIndicatorImage = circleIndicatorImage(diameter: 10)
        }
    }

    override func setUI() {
        addSubviews(imageScrollView, pageControl)

        imageScrollView.addSubview(imageStackView)

        imageViews.forEach { imageStackView.addArrangedSubview($0) }
    }

    override func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(self.snp.width)
        }

        imageScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageStackView.snp.makeConstraints {
            $0.edges.equalTo(imageScrollView.contentLayoutGuide)
            $0.height.equalTo(imageScrollView.frameLayoutGuide)
        }

        imageViews.forEach { imageView in
            imageView.snp.makeConstraints {
                $0.width.equalTo(imageScrollView.frameLayoutGuide)
            }
        }

        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageScrollView.snp.bottom).offset(12)
        }
    }

    private func indicatorIndex(for page: Int) -> Int {
        guard imageCount > 5 else { return page }

        switch page {
        case 0, 1:
            return page
        case imageCount - 2:
            return 3
        case imageCount - 1:
            return 4
        default:
            return 2
        }
    }

    private func circleIndicatorImage(diameter: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}

extension TimeLineCard: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 1 else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        let clampedPage = min(max(page, 0), max(imageCount - 1, 0))
        pageControl.currentPage = indicatorIndex(for: clampedPage)
    }
}
