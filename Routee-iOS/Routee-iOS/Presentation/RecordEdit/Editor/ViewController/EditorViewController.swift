//
//  EditorViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import PhotosUI
import SnapKit
import Then
import UIKit

final class EditorViewController: BaseUIViewController {

    // MARK: - Properties

    private let viewModel = EditorViewModel()
    private let recordEditResourceViewModel = RecordEditResourceViewModel()
    private let activityId: Int64?
    private let entryPoint: RecapEditorEntryPoint
    private var didTrackEditorOpened = false
    private var hasCompleted = false

    private enum TabIndex {
        static let recordEdit = 1
    }

    // MARK: - UI Properties

    private let rootView = EditorView()

    // MARK: - Initializer

    init(activityId: Int64?, entryPoint: RecapEditorEntryPoint) {
        self.activityId = activityId
        self.entryPoint = entryPoint
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard activityId != nil else { return }

        loadActivityEditorData()
        loadRecordEditResourceData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let activityId,
              !didTrackEditorOpened else { return }

        didTrackEditorOpened = true
        AnalyticsTracker.track(
            .recapEditorOpened,
            properties: [
                "activity_id": String(activityId),
                "entry_point": entryPoint.rawValue
            ]
        )
    }

    // MARK: - Private Methods

    private func loadActivityEditorData() {
        Task { [weak self] in
            guard let self,
                  let activityId else { return }

            do {
                try await viewModel.fetchActivityEditorData(activityId: activityId)

                guard let activityEditorModel = viewModel.activityEditorModel else { return }

                await MainActor.run {
                    self.rootView.configure(with: activityEditorModel)
                }

            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func loadRecordEditResourceData() {
        Task { [weak self] in
            guard let self,
                  let activityId else { return }

            do {
                try await recordEditResourceViewModel.fetchRecordEditResourceData(activityId: activityId)

                guard let recordEditResourceModel = recordEditResourceViewModel.recordEditResourceModel else { return }

                await MainActor.run {
                    self.rootView.configure(with: recordEditResourceModel)
                }

            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func popViewController() {
        if let activityId,
           !hasCompleted {
            AnalyticsTracker.track(
                .recapAbandoned,
                properties: [
                    "activity_id": String(activityId),
                    "has_edit": rootView.hasChanges
                ]
            )
        }

        navigateToRecordEditHome()
    }

    private func navigateToRecordEditHome() {
        guard let tabBarController = tabBarController as? TabBarViewController,
              let viewControllers = tabBarController.viewControllers,
              viewControllers.indices.contains(TabIndex.recordEdit),
              let recordEditNavigationController = viewControllers[TabIndex.recordEdit] as? UINavigationController
        else {
            navigationController?.popViewController(animated: false)
            return
        }

        let currentNavigationController = navigationController

        recordEditNavigationController.popToRootViewController(animated: false)
        tabBarController.setCustomTabBarHidden(false)
        tabBarController.selectTab(index: TabIndex.recordEdit)

        guard currentNavigationController !== recordEditNavigationController else { return }

        DispatchQueue.main.async { [weak currentNavigationController] in
            guard let rootViewController = currentNavigationController?.viewControllers.first else { return }

            currentNavigationController?.setViewControllers([rootViewController], animated: false)
        }
    }

    private func handleBackButtonTap() {
        guard rootView.hasChanges else {
            popViewController()
            return
        }

        presentStopEditingModal()
    }

    private func presentStopEditingModal() {
        let modal = ActionPrimaryModal(
            title: "편집을 중단하시겠습니까?",
            description: "편집 중단 시 변경 사항이 저장되지 않습니다.",
            leftButtonTitle: "취소",
            rightButtonTitle: "확인"
        ) { [weak self] in
            self?.popViewController()
        }

        present(modal, animated: true)
    }

    private func presentResetEditingModal() {
        guard rootView.hasChanges else { return }

        let modal = ActionPrimaryModal(
            title: "편집 내용을 초기화하시겠습니까?",
            description: "초기화 시 변경 사항이 저장되지 않습니다.",
            leftButtonTitle: "취소",
            rightButtonTitle: "확인"
        ) { [weak self] in
            self?.rootView.resetEditingContent()
        }

        present(modal, animated: true)
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    private func pushCropView(with image: UIImage) {
        let imageCropViewController = EditorImageCropViewController(image: image)

        imageCropViewController.onCropCompleted = { [weak self] croppedImage in
            self?.rootView.updateBackgroundImage(croppedImage)
        }

        navigationController?.pushViewController(imageCropViewController, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    private func pushCompleteView() {
        guard !hasCompleted,
              let navigationController else { return }

        let editedImage = rootView.makeEditedImage()
        let editCompleteViewController = EditCompleteViewController(
            activityId: activityId,
            editedImage: editedImage
        )

        hasCompleted = true
        navigationController.pushViewController(editCompleteViewController, animated: false)
        navigationController.navigationBar.isHidden = true

        if let activityId {
            AnalyticsTracker.track(
                .recapCompleted,
                properties: [
                    "activity_id": String(activityId),
                    "has_edit": rootView.hasChanges
                ]
            )
        }
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.setGesture()
        rootView.setAddTarget()
        rootView.setInitialState()

        rootView.onFirstChange = { [weak self] in
            guard let activityId = self?.activityId else { return }

            AnalyticsTracker.track(
                .recapEdited,
                properties: ["activity_id": String(activityId)]
            )
        }

        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.handleBackButtonTap()
        }

        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.rootView.playLottie {
                self?.pushCompleteView()
            }
        }

        rootView.setBackgroundTapAction { [weak self] in
            self?.presentImagePicker()
        }

        rootView.setResetButtonAction { [weak self] in
            self?.presentResetEditingModal()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditorViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        guard let result = results.first else {
            picker.dismiss(animated: true)
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self?.pushCropView(with: image)
                }
            }
        }
    }
}
