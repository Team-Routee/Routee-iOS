//
//  TimeLineCard.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class TimeLineCard: BaseUIView {
    private let imageScrollView = UIScrollView()
    private let imageStackView = UIStackView()
    private let pageControl = UIPageControl()

    private var imageContainerViews: [UIView] = []
    private var imageViews: [UIImageView] = []
    private var locationTags: [LocationTag] = []
    private var photoDownloadButtons: [PhotoDownloadButton] = []
    private var imageCount = 0
    
    init(images: [UIImage?], locations: [String?]? = nil) {
        var imageContainerViews: [UIView] = []
        var imageViews: [UIImageView] = []
        var locationTags: [LocationTag] = []
        var photoDownloadButtons: [PhotoDownloadButton] = []

        images.enumerated().forEach { index, image in
            let imageContainerView = UIView()
            let imageView = UIImageView()
            let photoDownloadButton = PhotoDownloadButton()
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true

            imageContainerView.addSubviews(imageView, photoDownloadButton)
            imageContainerViews.append(imageContainerView)
            imageViews.append(imageView)
            photoDownloadButtons.append(photoDownloadButton)

            guard let locations,
                  locations.indices.contains(index),
                  let location = Self.validLocationTitle(locations[index]) else { return }

            let locationTag = LocationTag(title: location)
            imageContainerView.addSubview(locationTag)
            locationTags.append(locationTag)
        }

        self.imageContainerViews = imageContainerViews
        self.imageViews = imageViews
        self.locationTags = locationTags
        self.photoDownloadButtons = photoDownloadButtons
        imageCount = images.count

        super.init(frame: .zero)

        zip(self.photoDownloadButtons, self.imageViews).forEach { button, imageView in
            button.configure(
                imageProvider: { [weak imageView] in imageView?.image },
                showToast: { [weak self] title in self?.showToast(title: title) }
            )
        }
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
            $0.hidesForSinglePage = true
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

        photoDownloadButtons.forEach {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.trailing.equalToSuperview().inset(14)
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

    func configure(imageUrls: [String], locations: [String?]? = nil) {
        imageViews.forEach { $0.kf.cancelDownloadTask() }
        imageStackView.arrangedSubviews.forEach {
            imageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        imageContainerViews.removeAll()
        imageViews.removeAll()
        locationTags.removeAll()
        photoDownloadButtons.removeAll()
        imageCount = imageUrls.count

        imageUrls.enumerated().forEach { index, imageUrl in
            let imageContainerView = UIView()
            let imageView = UIImageView()
            let photoDownloadButton = PhotoDownloadButton()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            photoDownloadButton.configure(
                imageProvider: { [weak imageView] in imageView?.image },
                showToast: { [weak self] title in self?.showToast(title: title) }
            )

            if let url = URL(string: imageUrl) {
                imageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "img_location1")
                )
            }

            imageContainerView.addSubviews(imageView, photoDownloadButton)
            imageStackView.addArrangedSubview(imageContainerView)
            imageContainerViews.append(imageContainerView)
            imageViews.append(imageView)
            photoDownloadButtons.append(photoDownloadButton)

            imageContainerView.snp.makeConstraints {
                $0.width.equalTo(imageScrollView.frameLayoutGuide)
            }

            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            photoDownloadButton.snp.makeConstraints {
                $0.top.equalToSuperview().inset(12)
                $0.trailing.equalToSuperview().inset(14)
            }

            guard let locations,
                  locations.indices.contains(index),
                  let location = Self.validLocationTitle(locations[index]) else { return }

            let locationTag = LocationTag(title: location)
            imageContainerView.addSubview(locationTag)
            locationTags.append(locationTag)

            locationTag.snp.makeConstraints {
                $0.top.leading.equalToSuperview().inset(12)
            }
        }

        pageControl.numberOfPages = min(imageCount, 5)
        pageControl.currentPage = 0
        imageScrollView.setContentOffset(.zero, animated: false)
    }

    private static func validLocationTitle(_ title: String?) -> String? {
        guard let title else { return nil }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? nil : trimmedTitle
    }

    private func showToast(title: String) {
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
            $0.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(toastWidth)
            $0.height.equalTo(37)
        }

        toastMessageView.layer.cornerRadius = 12
        toastMessageView.clipsToBounds = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.2) {
                toastMessageView.alpha = 0
            } completion: { _ in
                toastMessageView.removeFromSuperview()
            }
        }
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
