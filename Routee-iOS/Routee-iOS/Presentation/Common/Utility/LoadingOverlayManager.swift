//
//  LoadingOverlayManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/3/26.
//

import UIKit

import SnapKit

@MainActor
final class LoadingOverlayManager {

    static let shared = LoadingOverlayManager()

    private let overlayView = LoadingOverlayView()
    private var presentationCount = 0

    private init() { }

    func show(message: String = "데이터를 불러오고 있어요") {
        guard let window = keyWindow else { return }

        presentationCount += 1
        overlayView.startAnimation(message: message)

        guard overlayView.superview == nil else {
            window.bringSubviewToFront(overlayView)
            return
        }

        window.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func hide() {
        guard presentationCount > 0 else { return }

        presentationCount -= 1
        guard presentationCount == 0 else { return }

        overlayView.stopAnimation()
        overlayView.removeFromSuperview()
    }

    nonisolated func perform<T>(
        message: String = "데이터를 불러오고 있어요",
        operation: () async throws -> T
    ) async rethrows -> T {
        await MainActor.run {
            show(message: message)
        }

        do {
            let result = try await operation()

            await MainActor.run {
                hide()
            }

            return result
        } catch {
            await MainActor.run {
                hide()
            }

            throw error
        }
    }

    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
