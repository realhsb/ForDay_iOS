//
//  HobbySelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import Combine

class HobbySelectionViewController: BaseOnboardingViewController {

    // MARK: - Properties

    private let hobbyView = HobbySelectionView()
    private let viewModel: HobbySelectionViewModel

    // MARK: - Initialization

    init(viewModel: HobbySelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = hobbyView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 선택")
        setupCollectionView()
        setupActions()
        bind()
        loadHobbies()
    }

    private func loadHobbies() {
        Task {
            await viewModel.fetchHobbies()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.2)
    }

    // MARK: - Actions

    override func nextButtonTapped() {
        guard let selectedHobby = viewModel.selectedHobby else { return }
        viewModel.onHobbySelected?(selectedHobby)
        coordinator?.next(from: .hobby)
    }

    override func backButtonTapped() {
        coordinator?.dismissOnboarding()
    }
}

// MARK: - Setup

extension HobbySelectionViewController {
    private func setupCollectionView() {
        hobbyView.collectionView.delegate = self
        hobbyView.collectionView.dataSource = self
    }

    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customInputButtonTapped))
        hobbyView.customInputButtonView.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbyView.collectionView.reloadData()
                self?.hobbyView.updateCollectionViewHeight()
            }
            .store(in: &cancellables)

        viewModel.$selectedHobby
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                for cell in self.hobbyView.collectionView.visibleCells {
                    guard let indexPath = self.hobbyView.collectionView.indexPath(for: cell),
                          let hobbyCell = cell as? HobbyCollectionViewCell else { continue }
                    let hobby = self.viewModel.hobbies[indexPath.item]
                    let isSelected = self.viewModel.isSelected(at: indexPath.item)
                    hobbyCell.configure(with: hobby, isSelected: isSelected)
                }
            }
            .store(in: &cancellables)

        viewModel.$isNextButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
            }
            .store(in: &cancellables)
    }

    @objc private func customInputButtonTapped() {
        showCustomInputPopup()
    }

    private func showCustomInputPopup() {
        let popup = HobbyInputPopupViewController()
        popup.onSubmit = { [weak self] hobbyName in
            guard let self else { return }
            self.viewModel.setCustomHobby(hobbyName)
            self.hobbyView.updateCustomInputButton(hobbyName: hobbyName)
        }
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension HobbySelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hobbies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HobbyCollectionViewCell.identifier,
            for: indexPath
        ) as? HobbyCollectionViewCell else {
            return UICollectionViewCell()
        }

        let hobby = viewModel.hobbies[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(with: hobby, isSelected: isSelected)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HobbySelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectHobby(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HobbySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemSpacing: CGFloat = 8
        let itemWidth = (collectionView.bounds.width - interItemSpacing) / 2
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

#if DEBUG
#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.start()
    return nav
}
#endif
