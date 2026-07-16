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

    private var imageContainerViews: [UIView] = []
    private var imageViews: [UIImageView] = []
    private var locationTags: [LocationTag] = []
    private var imageCount = 0
    
    init(images: [UIImage?], locations: [String?]? = nil) {
        var imageContainerViews: [UIView] = []
        var imageViews: [UIImageView] = []
        var locationTags: [LocationTag] = []

        images.enumerated().forEach { index, image in
            let imageContainerView = UIView()
            let imageView = UIImageView()
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            imageContainerView.addSubview(imageView)
            imageContainerViews.append(imageContainerView)
            imageViews.append(imageView)

            guard let locations,
                  locations.indices.contains(index),
                  let location = locations[index] else { return }

            let locationTag = LocationTag(title: location)
            imageContainerView.addSubview(locationTag)
            locationTags.append(locationTag)
        }

        self.imageContainerViews = imageContainerViews
        self.imageViews = imageViews
        self.locationTags = locationTags
        imageCount = images.count

        super.init(frame: .zero)
    }

    convenience init(imageNames: [String], locations: [String?]? = nil) {
        self.init(images: imageNames.map { UIImage(named: $0) }, locations: locations)
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

        imageContainerViews.forEach { imageStackView.addArrangedSubview($0) }
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

        imageContainerViews.forEach { imageContainerView in
            imageContainerView.snp.makeConstraints {
                $0.width.equalTo(imageScrollView.frameLayoutGuide)
            }
        }

        imageViews.forEach {
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        locationTags.forEach {
            $0.snp.makeConstraints {
                $0.top.leading.equalToSuperview().inset(12)
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
