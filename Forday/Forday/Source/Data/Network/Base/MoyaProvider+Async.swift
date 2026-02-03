//
//  MoyaProvider+Async.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation
import Moya

extension MoyaProvider {

    /// Generic async/await wrapper for Moya requests with automatic JSON decoding and error handling
    /// - Parameter target: The target endpoint to request
    /// - Returns: Decoded response of type T
    /// - Throws: AppError with proper error classification
    func request<T: Decodable>(_ target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // Check if response is an error (4xx, 5xx)
                        if (400...599).contains(response.statusCode) {
                            // Try to parse server error
                            if let serverError = try? response.map(ServerErrorResponse.self) {
                                continuation.resume(throwing: AppError.server(serverError.toServerError()))
                                return
                            }
                        }

                        // Try to decode success response
                        let decoded = try response.map(T.self)
                        continuation.resume(returning: decoded)

                    } catch let decodingError as DecodingError {
                        print("❌ Decoding Error: \(decodingError)")
                        continuation.resume(throwing: AppError.decoding(decodingError))

                    } catch {
                        continuation.resume(throwing: AppError.unknown(error))
                    }

                case .failure(let error):
                    // Convert MoyaError to AppError
                    let appError = self.convertMoyaError(error)
                    continuation.resume(throwing: appError)
                }
            }
        }
    }

    /// Convert MoyaError to AppError
    private func convertMoyaError(_ error: MoyaError) -> AppError {
        switch error {
        case .underlying(let nsError, _):
            let urlError = nsError as? URLError
            switch urlError?.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .network(.noInternet)
            case .timedOut:
                return .network(.timeout)
            case .cancelled:
                return .network(.cancelled)
            default:
                return .network(.unknown)
            }

        default:
            return .unknown(error)
        }
    }
}
