//
//  ActivityRecordViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine
import PhotosUI
import SnapKit

class ActivityRecordViewController: UIViewController {

    // Properties

    private let recordView = ActivityRecordView()
    private let viewModel: ActivityRecordViewModel
    private var cancellables = Set<AnyCancellable>()
    private var activityDropdownView: ActivityDropdownView?
    private var privacyDropdownView: PrivacyDropdownView?

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Initialization

    init(hobbyId: Int, activityDetail: ActivityDetail? = nil) {
        self.viewModel = ActivityRecordViewModel(hobbyId: hobbyId, activityDetail: activityDetail)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lifecycle

    override func loadView() {
        view = recordView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
        setupForEditMode()
        fetchActivities()
    }
}

// Setup

extension ActivityRecordViewController {
    private func setupNavigationBar() {
        title = viewModel.isEditMode ? "내 활동 수정하기" : "내 활동 남기기"

        // 뒤로 가기 버튼 (수정 모드) 또는 X 버튼 (생성 모드)
        if viewModel.isEditMode {
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped)
            )
            backButton.tintColor = .label
            navigationItem.leftBarButtonItem = backButton
        } else {
            let closeButton = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped)
            )
            closeButton.tintColor = .label
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    private func setupActions() {
        // 스티커 선택
        recordView.stickerCollectionView.delegate = self
        recordView.stickerCollectionView.dataSource = self

        // 활동 드롭다운 버튼
        recordView.activityDropdownButton.addTarget(
            self,
            action: #selector(activityDropdownButtonTapped),
            for: .touchUpInside
        )

        // 사진 추가
        recordView.photoAddButton.addTarget(
            self,
            action: #selector(photoAddButtonTapped),
            for: .touchUpInside
        )

        // 공개범위 드롭다운 버튼
        recordView.privacyButton.addTarget(
            self,
            action: #selector(privacyButtonTapped),
            for: .touchUpInside
        )

        // 작성완료 버튼
        recordView.submitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )

        // 배경 탭하여 드롭다운 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // 메모 텍스트필드
        recordView.memoTextField.addTarget(
            self,
            action: #selector(memoTextFieldChanged),
            for: .editingChanged
        )
    }

    private func bind() {
        // 활동 선택
        viewModel.$selectedActivity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activity in
                self?.recordView.updateActivityTitle(activity?.content)
            }
            .store(in: &cancellables)

        // 작성 완료 버튼 활성화
        viewModel.$isSubmitEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                // 수정 모드에서는 항상 활성화
                let shouldEnable = self.viewModel.isEditMode ? true : isEnabled
                self.recordView.setSubmitButtonEnabled(shouldEnable)
            }
            .store(in: &cancellables)

        // 선택된 이미지
        viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.updatePhotoButton(with: image)
            }
            .store(in: &cancellables)
    }

    private func setupForEditMode() {
        if viewModel.isEditMode {
            // 수정 모드: 버튼 텍스트 변경
            recordView.setSubmitButtonTitle("수정완료")

            // 메모 설정
            recordView.memoTextField.text = viewModel.memo
            recordView.updateMemoCount(viewModel.memo.count)
        }
    }

    private func fetchActivities() {
        Task {
            do {
                try await viewModel.fetchActivityList()
            } catch {
                print("❌ 활동 목록 로드 실패: \(error)")
            }
        }
    }
}

// Actions

extension ActivityRecordViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func activityDropdownButtonTapped() {
        if activityDropdownView != nil {
            dismissActivityDropdown()
        } else {
            showActivityDropdown()
        }
    }

    @objc private func backgroundTapped() {
        dismissActivityDropdown()
        dismissPrivacyDropdown()
    }

    @objc private func photoAddButtonTapped() {
        // 이미지가 이미 선택된 경우 삭제 버튼이 눌린 것
        if viewModel.selectedImage != nil {
            deletePhoto()
        } else {
            presentPhotoPicker()
        }
    }

    @objc private func privacyButtonTapped() {
        if privacyDropdownView != nil {
            dismissPrivacyDropdown()
        } else {
            showPrivacyDropdown()
        }
    }

    @objc private func memoTextFieldChanged() {
        let text = recordView.memoTextField.text ?? ""

        // 200자 제한
        if text.count > 200 {
            let limitedText = String(text.prefix(200))
            recordView.memoTextField.text = limitedText
            viewModel.updateMemo(limitedText)
            recordView.updateMemoCount(200)
        } else {
            viewModel.updateMemo(text)
            recordView.updateMemoCount(text.count)
        }
    }

    @objc private func submitButtonTapped() {
        Task {
            do {
                let result = try await viewModel.submitActivityRecord()
                await MainActor.run {
                    print("✅ 활동 기록 작성 성공: \(result.message)")

                    // Notify HomeViewController to refresh sticker board
                    AppEventBus.shared.activityRecordCreated.send(viewModel.currentHobbyId)

                    dismiss(animated: true)
                }
            } catch ActivityRecordError.updateNotSupported {
                await MainActor.run {
                    print("⚠️ 수정 기능은 아직 구현되지 않았습니다")
                    showErrorAlert(
                        title: "기능 준비 중",
                        message: "활동 기록 수정 기능은 곧 제공될 예정입니다."
                    )
                }
            } catch ActivityRecordError.missingRequiredFields {
                await MainActor.run {
                    print("❌ 필수 항목이 누락되었습니다")
                    showErrorAlert(
                        title: "입력 오류",
                        message: "활동과 스티커를 모두 선택해주세요."
                    )
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 기록 작성 실패: \(error)")
                    showErrorAlert(
                        title: "오류",
                        message: "활동 기록을 저장하는 중 오류가 발생했습니다.\n다시 시도해주세요."
                    )
                }
            }
        }
    }

    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showActivityDropdown() {
        guard activityDropdownView == nil else { return }

        let dropdown = ActivityDropdownView(activities: viewModel.activities)
        dropdown.onActivitySelected = { [weak self] activity in
            self?.viewModel.selectActivity(activity)
            self?.dismissActivityDropdown()
        }

        dropdown.show(in: view, below: recordView.activityDropdownButton)
        activityDropdownView = dropdown
    }

    private func dismissActivityDropdown() {
        activityDropdownView?.dismiss()
        activityDropdownView = nil
    }

    private func showPrivacyDropdown() {
        guard privacyDropdownView == nil else { return }

        let dropdown = PrivacyDropdownView(selectedPrivacy: viewModel.privacy)
        dropdown.onPrivacySelected = { [weak self] privacy in
            self?.viewModel.selectPrivacy(privacy)
            self?.updatePrivacyButton(privacy)
            self?.dismissPrivacyDropdown()
        }

        dropdown.show(in: view, below: recordView.privacyButton)
        privacyDropdownView = dropdown
    }

    private func dismissPrivacyDropdown() {
        privacyDropdownView?.dismiss()
        privacyDropdownView = nil
    }

    private func updatePrivacyButton(_ privacy: Privacy) {
        var config = recordView.privacyButton.configuration
        config?.title = privacy.title
        recordView.privacyButton.configuration = config
    }

    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func deletePhoto() {
        Task {
            do {
                try await viewModel.deleteImage()
            } catch {
                print("❌ 이미지 삭제 실패: \(error)")
            }
        }
    }

    private func updatePhotoButton(with image: UIImage?) {
        guard let image = image else {
            // 이미지 없음 - 원래 상태로 복원
            recordView.photoAddButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            recordView.photoAddButton.tintColor = .systemGray
            recordView.photoAddButton.backgroundColor = .white
            return
        }

        // 선택된 이미지 표시
        recordView.photoAddButton.setImage(image, for: .normal)
        recordView.photoAddButton.imageView?.contentMode = .scaleAspectFill
        recordView.photoAddButton.tintColor = nil

        // X 아이콘 추가
        addDeleteIconToPhotoButton()
    }

    private func addDeleteIconToPhotoButton() {
        // 기존 X 아이콘 제거
        recordView.photoAddButton.subviews.forEach { view in
            if view.tag == 999 {
                view.removeFromSuperview()
            }
        }

        let deleteButton = UIButton()
        deleteButton.tag = 999
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = .black.withAlphaComponent(0.6)
        deleteButton.layer.cornerRadius = 10
        deleteButton.clipsToBounds = true

        recordView.photoAddButton.addSubview(deleteButton)

        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-2)
            $0.width.height.equalTo(20)
        }
    }
}

// UICollectionView

extension ActivityRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.stickers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as? StickerCell else {
            return UICollectionViewCell()
        }

        let sticker = viewModel.stickers[indexPath.item]
        cell.configure(with: sticker, isSelected: viewModel.selectedSticker == sticker)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sticker = viewModel.stickers[indexPath.item]
        viewModel.selectSticker(sticker)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
}

// PHPickerViewControllerDelegate

extension ActivityRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ 이미지 로드 실패: \(error)")
                return
            }

            guard let image = object as? UIImage else {
                print("❌ 이미지 변환 실패")
                return
            }

            // 이미지 업로드
            Task {
                do {
                    try await self.viewModel.uploadImage(image)
                    print("✅ 이미지 업로드 성공")
                } catch {
                    print("❌ 이미지 업로드 실패: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    let nav = UINavigationController()
//    let vc = ActivityRecordViewController()
//    nav.setViewControllers([vc], animated: false)
//    return nav
//}
