//
//  ServerErrorCode.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

/// 서버에서 반환하는 모든 에러 코드를 관리하는 파일
/// 각 API별로 발생 가능한 에러를 문서화하고, 타입 안전성을 제공합니다.

// MARK: - Server Error Codes

/// 서버 에러 클래스 이름 상수
enum ServerErrorCode {

    // MARK: - Activity Record Errors (활동 기록 생성/수정)

    /// 존재하지 않는 활동 ID
    /// - API: POST /records, PATCH /records/{recordId}
    /// - Status: 404
    static let activityNotFound = "ACTIVITY_NOT_FOUND"

    /// 활동 소유자가 아닐 때
    /// - API: POST /records, PATCH /records/{recordId}
    /// - Status: 403
    static let notActivityOwner = "NOT_ACTIVITY_OWNER"

    /// S3 이미지가 제대로 업로드 안된 상태일 때
    /// - API: POST /records
    /// - Status: 404
    static let s3ImageNotFound = "S3_IMAGE_NOT_FOUND"

    /// 해당 취미에 대해 이미 활동 기록 작성한 경우
    /// - API: POST /records
    /// - Status: 400
    static let alreadyRecordedToday = "ALREADY_RECORDED_TODAY"

    /// 현재 취미 상태에서 작업을 수행할 수 없는 경우
    /// - API: POST /records, PATCH /hobbies/{hobbyId}
    /// - Status: 400
    static let invalidHobbyStatus = "INVALID_HOBBY_STATUS"

    /// 목표일이 66일 취미에 대해 이미 66개의 스티커를 다 채운 경우
    /// - API: POST /records
    /// - Status: 400
    static let stickerCompletionReached = "STICKER_COMPLETION_REACHED"

    // MARK: - Activity Detail Errors (활동 상세 조회)

    /// 존재하지 않는 활동 기록
    /// - API: GET /records/{recordId}
    /// - Status: 404
    static let activityRecordNotFound = "ACTIVITY_RECORD_NOT_FOUND"

    /// 친구만 조회 가능한 글
    /// - API: GET /records/{recordId}
    /// - Status: 403
    static let friendOnlyAccess = "FRIEND_ONLY_ACCESS"

    /// 작성자만 볼 수 있는 글
    /// - API: GET /records/{recordId}
    /// - Status: 403
    static let privateRecord = "PRIVATE_RECORD"

    // MARK: - Token/Auth Errors

    /// 토큰 만료 (자동 갱신됨)
    /// - API: All authenticated endpoints
    /// - Status: 401
    static let tokenExpired = "TOKEN_EXPIRED"

    /// 로그인 세션 만료 (재로그인 필요)
    /// - API: All authenticated endpoints
    /// - Status: 401
    static let loginExpired = "LOGIN_EXPIRED"

    // MARK: - User Errors

    /// 닉네임 중복
    /// - API: POST /users/nickname
    /// - Status: 409
    static let nicknameDuplicated = "NICKNAME_DUPLICATED"

    /// 존재하지 않는 사용자
    /// - API: GET /users/{userId}
    /// - Status: 404
    static let userNotFound = "USER_NOT_FOUND"

    // MARK: - Hobby Errors

    /// 존재하지 않는 취미
    /// - API: GET /hobbies/{hobbyId}, PATCH /hobbies/{hobbyId}
    /// - Status: 404
    static let hobbyNotFound = "HOBBY_NOT_FOUND"

    /// 취미 개수 제한 초과 (최대 2개)
    /// - API: POST /hobbies
    /// - Status: 400
    static let hobbyLimitExceeded = "HOBBY_LIMIT_EXCEEDED"
}

// MARK: - Error Recovery Actions

/// 에러 발생 시 복구 액션 타입
enum ErrorRecoveryAction {
    case dismiss                    // 현재 화면 닫기
    case navigateBack              // 이전 화면으로 이동
    case retry                     // 재시도
    case showLogin                 // 로그인 화면 표시
    case none                      // 액션 없음 (메시지만 표시)
}

// MARK: - Error Metadata

/// API별 에러 메타데이터
struct APIErrorMetadata {
    let errorCode: String
    let userFriendlyTitle: String
    let suggestedAction: ErrorRecoveryAction

    init(code: String, title: String, action: ErrorRecoveryAction) {
        self.errorCode = code
        self.userFriendlyTitle = title
        self.suggestedAction = action
    }
}

// MARK: - API Error Mappings

/// 활동 기록 API 에러 매핑
enum ActivityRecordAPIError {
    static let metadata: [String: APIErrorMetadata] = [
        ServerErrorCode.activityNotFound: APIErrorMetadata(
            code: ServerErrorCode.activityNotFound,
            title: "활동을 찾을 수 없음",
            action: .dismiss
        ),
        ServerErrorCode.notActivityOwner: APIErrorMetadata(
            code: ServerErrorCode.notActivityOwner,
            title: "권한 없음",
            action: .dismiss
        ),
        ServerErrorCode.s3ImageNotFound: APIErrorMetadata(
            code: ServerErrorCode.s3ImageNotFound,
            title: "이미지 업로드 실패",
            action: .none
        ),
        ServerErrorCode.alreadyRecordedToday: APIErrorMetadata(
            code: ServerErrorCode.alreadyRecordedToday,
            title: "오늘 이미 기록함",
            action: .dismiss
        ),
        ServerErrorCode.invalidHobbyStatus: APIErrorMetadata(
            code: ServerErrorCode.invalidHobbyStatus,
            title: "취미 상태 오류",
            action: .dismiss
        ),
        ServerErrorCode.stickerCompletionReached: APIErrorMetadata(
            code: ServerErrorCode.stickerCompletionReached,
            title: "스티커 달성 완료",
            action: .dismiss
        )
    ]
}

/// 활동 상세 API 에러 매핑
enum ActivityDetailAPIError {
    static let metadata: [String: APIErrorMetadata] = [
        ServerErrorCode.activityRecordNotFound: APIErrorMetadata(
            code: ServerErrorCode.activityRecordNotFound,
            title: "활동 기록을 찾을 수 없음",
            action: .navigateBack
        ),
        ServerErrorCode.friendOnlyAccess: APIErrorMetadata(
            code: ServerErrorCode.friendOnlyAccess,
            title: "접근 권한 없음",
            action: .navigateBack
        ),
        ServerErrorCode.privateRecord: APIErrorMetadata(
            code: ServerErrorCode.privateRecord,
            title: "접근 권한 없음",
            action: .navigateBack
        )
    ]
}

/// 사용자 API 에러 매핑
enum UserAPIError {
    static let metadata: [String: APIErrorMetadata] = [
        ServerErrorCode.nicknameDuplicated: APIErrorMetadata(
            code: ServerErrorCode.nicknameDuplicated,
            title: "닉네임 중복",
            action: .none
        ),
        ServerErrorCode.userNotFound: APIErrorMetadata(
            code: ServerErrorCode.userNotFound,
            title: "사용자를 찾을 수 없음",
            action: .navigateBack
        )
    ]
}

/// 취미 API 에러 매핑
enum HobbyAPIError {
    static let metadata: [String: APIErrorMetadata] = [
        ServerErrorCode.hobbyNotFound: APIErrorMetadata(
            code: ServerErrorCode.hobbyNotFound,
            title: "취미를 찾을 수 없음",
            action: .navigateBack
        ),
        ServerErrorCode.hobbyLimitExceeded: APIErrorMetadata(
            code: ServerErrorCode.hobbyLimitExceeded,
            title: "취미 개수 초과",
            action: .none
        ),
        ServerErrorCode.invalidHobbyStatus: APIErrorMetadata(
            code: ServerErrorCode.invalidHobbyStatus,
            title: "취미 상태 오류",
            action: .dismiss
        )
    ]
}

// MARK: - Helper Extensions

extension ServerError {
    /// 에러 코드에 해당하는 메타데이터 조회
    func metadata(for api: [String: APIErrorMetadata]) -> APIErrorMetadata? {
        return api[errorClassName]
    }

    /// 활동 기록 API 메타데이터
    var activityRecordMetadata: APIErrorMetadata? {
        return ActivityRecordAPIError.metadata[errorClassName]
    }

    /// 활동 상세 API 메타데이터
    var activityDetailMetadata: APIErrorMetadata? {
        return ActivityDetailAPIError.metadata[errorClassName]
    }

    /// 사용자 API 메타데이터
    var userMetadata: APIErrorMetadata? {
        return UserAPIError.metadata[errorClassName]
    }

    /// 취미 API 메타데이터
    var hobbyMetadata: APIErrorMetadata? {
        return HobbyAPIError.metadata[errorClassName]
    }
}
