//
//  AppleAuthService.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//


import Foundation
import AuthenticationServices


final class AppleAuthService: NSObject, SocialAuthService {

    enum AppleAuthError: Error {
        case userCancelled
        case failed(Error)
        case invalidResponse
        case authorizationCodeNotFound
        case loginAlreadyInProgress
    }

    private var continuation: CheckedContinuation<String, Error>?
    private var isLoginInProgress = false

    func login() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // 재진입 방지
            guard !isLoginInProgress else {
                continuation.resume(throwing: AppleAuthError.loginAlreadyInProgress)
                return
            }

            isLoginInProgress = true
            self.continuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthService: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer {
            isLoginInProgress = false
            continuation = nil
        }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleAuthError.invalidResponse)
            return
        }

        // authorization_code 추출
        guard let authorizationCodeData = appleIDCredential.authorizationCode,
              let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
            continuation?.resume(throwing: AppleAuthError.authorizationCodeNotFound)
            return
        }

        continuation?.resume(returning: authorizationCode)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer {
            isLoginInProgress = false
            continuation = nil
        }

        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                continuation?.resume(throwing: AppleAuthError.userCancelled)
            default:
                continuation?.resume(throwing: AppleAuthError.failed(error))
            }
        } else {
            continuation?.resume(throwing: AppleAuthError.failed(error))
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("No window scene available for Apple Sign In")
            return UIWindow()
        }
        return window
    }
}
