//
//  ManageHobbyCoverViewController.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import Combine
import PhotosUI

class ManageHobbyCoverViewController: UIViewController {

    // MARK: - Properties

    private let manageCoverView = ManageHobbyCoverView()
    private let viewModel: ManageHobbyCoverViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: ManageHobbyCoverViewModel = ManageHobbyCoverViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = manageCoverView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        setupActions()
        bind()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "취미 대표사진 관리"
    }

    private func setupCollectionView() {
        manageCoverView.collectionView.dataSource = self
        manageCoverView.collectionView.delegate = self
    }

    private func setupActions() {
        // Hobby Selection Button
        manageCoverView.hobbySelectionButton.addTarget(
            self,
            action: #selector(hobbySelectionButtonTapped),
            for: .touchUpInside
        )

        // Select Cover Button
        manageCoverView.selectCoverButton.addTarget(
            self,
            action: #selector(selectCoverButtonTapped),
            for: .touchUpInside
        )
    }

    private func bind() {
        // Hobbies
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbies in
                // Update hobby selection if needed
            }
            .store(in: &cancellables)

        // Selected Hobby
        viewModel.$selectedHobby
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobby in
                self?.manageCoverView.updateHobbyLabel(hobby.hobbyName)
            }
            .store(in: &cancellables)

        // Activity Records
        viewModel.$activityRecords
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                self?.manageCoverView.collectionView.reloadData()
                self?.manageCoverView.showEmptyState(records.isEmpty)
            }
            .store(in: &cancellables)

        // Selected Record
        viewModel.$selectedRecordId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.manageCoverView.selectCoverButton.isEnabled = selectedId != nil
                self?.manageCoverView.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // Error Handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func hobbySelectionButtonTapped() {
        showHobbySelectionMenu()
    }

    @objc private func selectCoverButtonTapped() {
        CoverImageOptionSheet.present(
            on: self,
            onGallerySelected: { [weak self] in
                self?.handleGallerySelection()
            },
            onActivitySelected: { [weak self] in
                self?.handleActivitySelection()
            }
        )
    }

    // MARK: - Hobby Selection

    private func showHobbySelectionMenu() {
        let alert = UIAlertController(title: "취미 선택", message: nil, preferredStyle: .actionSheet)

        for hobby in viewModel.hobbies {
            let action = UIAlertAction(title: hobby.hobbyName, style: .default) { [weak self] _ in
                self?.viewModel.selectedHobby = hobby
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = manageCoverView.hobbySelectionButton
            popoverController.sourceRect = manageCoverView.hobbySelectionButton.bounds
        }

        present(alert, animated: true)
    }

    // MARK: - Cover Image Selection

    private func handleGallerySelection() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func handleActivitySelection() {
        Task {
            do {
                let message = try await viewModel.updateCoverImageWithRecord()

                await MainActor.run {
                    guard let hobbyName = self.viewModel.selectedHobby?.hobbyName else { return }
                    ToastView.show(message: "\(hobbyName) 대표사진 변경 완료!")
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    self.handleError(appError)
                }
            } catch {
                await MainActor.run {
                    self.handleError(.unknown(error))
                }
            }
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: AppError) {
        let alert = UIAlertController(
            title: "오류",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ManageHobbyCoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.activityRecords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ActivityRecordCell",
            for: indexPath
        ) as? ActivityRecordCell else {
            return UICollectionViewCell()
        }

        let item = viewModel.activityRecords[indexPath.item]
        let isSelected = viewModel.selectedRecordId == item.activityRecordId
        cell.configure(with: item.sticker, isSelected: isSelected)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ManageHobbyCoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.activityRecords[indexPath.item]
        viewModel.toggleRecordSelection(item.activityRecordId)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ManageHobbyCoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ManageHobbyCoverViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }

            Task {
                do {
                    let message = try await self?.viewModel.updateCoverImageWithGallery(image: image)

                    await MainActor.run {
                        guard let self = self,
                              let hobbyName = self.viewModel.selectedHobby?.hobbyName else { return }
                        ToastView.show(message: "\(hobbyName) 대표사진 변경 완료!")
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch let appError as AppError {
                    await MainActor.run {
                        self?.handleError(appError)
                    }
                } catch {
                    await MainActor.run {
                        self?.handleError(.unknown(error))
                    }
                }
            }
        }
    }
}
