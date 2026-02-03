//
//  UIViewController+ErrorHandling.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit

// MARK: - Error Handling Extension

extension UIViewController {

    /// 공통 에러 처리 메서드
    /// - Parameters:
    ///   - error: AppError 타입의 에러
    ///   - apiErrorMetadata: API별 에러 메타데이터 (optional)
    ///   - customHandler: 커스텀 에러 처리 클로저 (optional)
    func handleAppError(
        _ error: AppError,
        using apiErrorMetadata: ((ServerError) -> APIErrorMetadata?)? = nil,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        // 커스텀 핸들러가 있고, 처리를 완료했으면 종료
        if let customHandler = customHandler, customHandler(error) {
            return
        }

        var title: String
        let message = error.userMessage
        var actions: [UIAlertAction] = []

        switch error {
        case .network:
            title = "네트워크 오류"
            // 네트워크 에러는 재시도 가능
            actions.append(UIAlertAction(title: "확인", style: .default))

        case .server(let serverError):
            // API별 메타데이터가 제공된 경우 사용
            if let metadataProvider = apiErrorMetadata,
               let metadata = metadataProvider(serverError) {
                title = metadata.userFriendlyTitle

                // 복구 액션에 따라 UIAlertAction 생성
                let action = createAlertAction(for: metadata.suggestedAction)
                actions.append(contentsOf: action)
            } else {
                // 메타데이터가 없으면 기본 처리
                title = "오류"
                actions.append(UIAlertAction(title: "확인", style: .default))
            }

        case .decoding, .unknown:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))
        }

        // Alert 표시
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    /// 복구 액션에 따른 UIAlertAction 생성
    private func createAlertAction(for action: ErrorRecoveryAction) -> [UIAlertAction] {
        switch action {
        case .dismiss:
            return [UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            }]

        case .navigateBack:
            return [UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }]

        case .retry:
            // 재시도 액션은 화면마다 다를 수 있으므로 customHandler에서 처리
            return [UIAlertAction(title: "확인", style: .default)]

        case .showLogin:
            return [UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                // TODO: 로그인 화면으로 이동
                self?.dismiss(animated: true)
            }]

        case .none:
            return [UIAlertAction(title: "확인", style: .default)]
        }
    }
}

// MARK: - Convenience Methods

extension UIViewController {

    /// 활동 기록 API 에러 처리
    func handleActivityRecordError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(
            error,
            using: { $0.activityRecordMetadata },
            customHandler: customHandler
        )
    }

    /// 활동 상세 API 에러 처리
    func handleActivityDetailError(
        _ error: AppError,
        onRetry: (() -> Void)? = nil
    ) {
        handleAppError(
            error,
            using: { $0.activityDetailMetadata },
            customHandler: { [weak self] error in
                // 네트워크 에러는 재시도 가능
                if case .network = error, let retry = onRetry {
                    self?.showRetryAlert(message: error.userMessage, onRetry: retry)
                    return true
                }
                return false
            }
        )
    }

    /// 사용자 API 에러 처리
    func handleUserError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(
            error,
            using: { $0.userMetadata },
            customHandler: customHandler
        )
    }

    /// 취미 API 에러 처리
    func handleHobbyError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(
            error,
            using: { $0.hobbyMetadata },
            customHandler: customHandler
        )
    }

    /// 반응 API 에러 처리
    func handleReactionError(
        _ error: AppError,
        customHandler: ((AppError) -> Bool)? = nil
    ) {
        handleAppError(
            error,
            using: { $0.reactionMetadata },
            customHandler: customHandler
        )
    }

    /// 재시도 Alert 표시 (네트워크 에러용)
    private func showRetryAlert(message: String, onRetry: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "네트워크 오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in
            onRetry()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
