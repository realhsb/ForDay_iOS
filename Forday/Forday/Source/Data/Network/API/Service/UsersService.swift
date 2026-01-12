//
//  UsersService.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation
import Moya

final class UsersService {
    
    private let provider: MoyaProvider<UsersTarget>
    
    init(provider: MoyaProvider<UsersTarget> = MoyaProvider<UsersTarget>(plugins: [MoyaLoggingPlugin()])) {
        self.provider = provider
    }
    
    // MARK: - Nickname Availability Check
    
    func checkNicknameAvailability(nickname: String) async throws -> DTO.NicknameAvailabilityResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.nicknameAvailability(nickname: nickname)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try JSONDecoder().decode(DTO.NicknameAvailabilityResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
