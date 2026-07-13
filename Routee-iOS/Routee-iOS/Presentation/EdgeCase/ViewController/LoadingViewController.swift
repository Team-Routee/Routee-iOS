//
//  LoadingViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import UIKit

import Lottie

final class LoadingViewController: BaseUIViewController {

    // MARK: - UI Properties

    private let rootView = LoadingView()

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    // MARK: - UI Setting

    override func setView() {
        rootView.lottieView.contentMode = .scaleAspectFit
        rootView.lottieView.loopMode = .loop
        rootView.lottieView.play()
    }
}
