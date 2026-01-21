//
//  ActivityWriteViewController.swift
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

    private let writeView = ActivityRecordView()
    private let viewModel: ActivityRecordViewModel
    private var cancellables = Set<AnyCancellable>()
    private var activityDropdownView: ActivityDropdownView?
    private var privacyDropdownView: PrivacyDropdownView?

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Initialization

    init(hobbyId: Int) {
        self.viewModel = ActivityRecordViewModel(hobbyId: hobbyId)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Lifecycle

    override func loadView() {
        view = writeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
        fetchActivities()
    }
}

// Setup

extension ActivityRecordViewController {
    private func setupNavigationBar() {
        title = "내 활동 남기기"
        
        // X 버튼
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupActions() {
        // 스티커 선택
        writeView.stickerCollectionView.delegate = self
        writeView.stickerCollectionView.dataSource = self

        // 활동 드롭다운 버튼
        writeView.activityDropdownButton.addTarget(
            self,
            action: #selector(activityDropdownButtonTapped),
            for: .touchUpInside
        )

        // 사진 추가
        writeView.photoAddButton.addTarget(
            self,
            action: #selector(photoAddButtonTapped),
            for: .touchUpInside
        )

        // 공개범위 드롭다운 버튼
        writeView.privacyButton.addTarget(
            self,
            action: #selector(privacyButtonTapped),
            for: .touchUpInside
        )

        // 작성완료 버튼
        writeView.submitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
        )

        // 배경 탭하여 드롭다운 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        // 메모 텍스트필드
        writeView.memoTextField.addTarget(
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
                self?.writeView.updateActivityTitle(activity?.content)
            }
            .store(in: &cancellables)

        // 작성 완료 버튼 활성화
        viewModel.$isSubmitEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.writeView.setSubmitButtonEnabled(isEnabled)
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
        viewModel.updateMemo(writeView.memoTextField.text ?? "")
    }

    @objc private func submitButtonTapped() {
        Task {
            do {
                let result = try await viewModel.submitActivityRecord()
                await MainActor.run {
                    print("✅ 활동 기록 작성 성공: \(result.message)")
                    dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 기록 작성 실패: \(error)")
                    // TODO: 에러 처리 UI 표시
                }
            }
        }
    }

    private func showActivityDropdown() {
        guard activityDropdownView == nil else { return }

        let dropdown = ActivityDropdownView(activities: viewModel.activities)
        dropdown.onActivitySelected = { [weak self] activity in
            self?.viewModel.selectActivity(activity)
            self?.dismissActivityDropdown()
        }

        dropdown.show(in: view, below: writeView.activityDropdownButton)
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

        dropdown.show(in: view, below: writeView.privacyButton)
        privacyDropdownView = dropdown
    }

    private func dismissPrivacyDropdown() {
        privacyDropdownView?.dismiss()
        privacyDropdownView = nil
    }

    private func updatePrivacyButton(_ privacy: Privacy) {
        var config = writeView.privacyButton.configuration
        config?.title = privacy.title
        writeView.privacyButton.configuration = config
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
            writeView.photoAddButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
            writeView.photoAddButton.tintColor = .systemGray
            writeView.photoAddButton.backgroundColor = .white
            return
        }

        // 선택된 이미지 표시
        writeView.photoAddButton.setImage(image, for: .normal)
        writeView.photoAddButton.imageView?.contentMode = .scaleAspectFill
        writeView.photoAddButton.tintColor = nil

        // X 아이콘 추가
        addDeleteIconToPhotoButton()
    }

    private func addDeleteIconToPhotoButton() {
        // 기존 X 아이콘 제거
        writeView.photoAddButton.subviews.forEach { view in
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

        writeView.photoAddButton.addSubview(deleteButton)

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
//    let vc = ActivityWriteViewController()
//    nav.setViewControllers([vc], animated: false)
//    return nav
//}
