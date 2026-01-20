//
//  ActivityWriteViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import UIKit
import Combine

class ActivityWriteViewController: UIViewController {
    
    // Properties
    
    private let writeView = ActivityWriteView()
    private let viewModel = ActivityWriteViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?
    
    // Lifecycle
    
    override func loadView() {
        view = writeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()
    }
}

// Setup

extension ActivityWriteViewController {
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
        
        // 사진 추가
        writeView.photoAddButton.addTarget(
            self,
            action: #selector(photoAddButtonTapped),
            for: .touchUpInside
        )
        
        // 작성완료 버튼
        writeView.submitButton.addTarget(
            self,
            action: #selector(submitButtonTapped),
            for: .touchUpInside
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
    }
}

// Actions

extension ActivityWriteViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func photoAddButtonTapped() {
        // 이미지가 이미 선택된 경우 삭제 버튼이 눌린 것
        if viewModel.selectedImage != nil {
            deletePhoto()
        } else {
            presentPhotoPicker()
        }
    }
    
    @objc private func submitButtonTapped() {
        // TODO: 활동 저장
        print("작성완료 탭")
        dismiss(animated: true)
    }
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
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
}

// UICollectionView

extension ActivityWriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

extension ActivityWriteViewController: PHPickerViewControllerDelegate {
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

