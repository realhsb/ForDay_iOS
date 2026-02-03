# API null 응답 안전하게 처리하기 - Result Enum 패턴

## 🎯 문제 상황

현재 아키텍처에서는 `BaseResponse` 프로토콜이 `data` 필드를 non-optional로 정의합니다:

```swift
protocol BaseResponse: Codable {
    associatedtype DataType: Codable
    var data: DataType { get }  // ← nil 불가
}
```

하지만 백엔드에서 **정상 응답으로 `data: null`을 반환**하는 경우 (예: 진행 중인 취미가 없을 때) 디코딩이 실패하고 앱이 크래시됩니다.

### 핵심 인사이트

`data: null`은 **에러가 아니라 정상적인 비즈니스 상태**입니다.
- ❌ Fallback 데이터로 가리면 안 됨
- ✅ 명확한 도메인 상태로 표현해야 함
- ✅ UI는 각 상태별로 적절한 화면을 보여줘야 함

---

## 💡 제안하는 해결 방법

**핵심 아이디어**: `Result enum`으로 비즈니스 상태를 명확하게 구분

### 1단계: Generic 응답 타입 추가

```swift
// DTO가 null일 수 있는 응답용
struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let data: T?  // ← Optional로 처리 (디코딩 크래시 방지)
}
```

### 2단계: Result Enum으로 비즈니스 상태 명확화

```swift
enum StickerBoardResult {
    case loaded(StickerBoard)           // 데이터 있음 (스티커 1개 이상)
    case noHobbyInProgress              // data: null (정상 상태)
    case emptyBoard(StickerBoard)       // 취미는 있지만 stickers: []
}
```

**왜 Result enum인가?**
- `nil` 반환은 애매함 (에러? 상태? 로딩 실패?)
- UI가 각 상태별로 **다른 화면**을 보여줘야 함
- 컴파일 타임에 모든 케이스 처리 강제

### 3단계: DTO는 순수하게 (toDomain 제거)

```swift
extension DTO {
    struct StickerBoardDTO: Decodable {
        let hobbyId: Int
        let durationSet: Bool
        // ... 기타 필드
        let stickers: [StickerDTO]?  // 안전하게 optional

        struct StickerDTO: Decodable {
            let activityRecordId: Int?
            let sticker: String?
        }
    }
}
```

### 4단계: Repository가 비즈니스 상태로 변환

```swift
func fetchStickerBoard(...) async throws -> StickerBoardResult {
    do {
        let response = try await service.fetchStickerBoard(...)

        // Case 4: 진행 중인 취미 없음 (정상 상태)
        guard let dto = response.data else {
            return .noHobbyInProgress
        }

        // DTO → Domain 변환 (nil 필터링)
        let stickers = dto.stickers?
            .compactMap { item -> StickerBoardItem? in
                guard let id = item.activityRecordId,
                      let sticker = item.sticker else { return nil }
                return StickerBoardItem(activityRecordId: id, sticker: sticker)
            } ?? []

        let board = StickerBoard(
            hobbyId: dto.hobbyId,
            durationSet: dto.durationSet,
            // ...
            stickers: stickers
        )

        // Case 5: 취미는 있는데 스티커가 아직 없음
        if stickers.isEmpty {
            return .emptyBoard(board)
        }

        return .loaded(board)

    } catch {
        // 진짜 에러 (네트워크, 디코딩 실패 등)만 fallback
        #if DEBUG
        print("⚠️ 스티커판 API 실패 - 목 데이터 사용")
        return .loaded(fallbackProvider.fallbackStickerBoard())
        #else
        throw error
        #endif
    }
}
```

### 5단계: ViewModel/ViewController에서 상태별 처리

```swift
func loadStickerBoard() async {
    do {
        let result = try await repository.fetchStickerBoard(...)

        await MainActor.run {
            switch result {
            case .loaded(let board):
                self.showStickerBoard(board)

            case .noHobbyInProgress:
                self.showEmptyState(
                    title: "아직 시작한 취미가 없어요",
                    message: "새로운 취미를 시작해보세요!"
                )

            case .emptyBoard(let board):
                self.showEmptyBoard(
                    message: "첫 활동을 기록하고 스티커를 채워보세요!",
                    boardInfo: board
                )
            }
        }
    } catch {
        self.showError(error)
    }
}
```

---

## 🔄 데이터 플로우 비교

### 기존 방식
```
API → Service → DTO.toDomain() → Repository → UseCase → UI
                     ↓
              ❌ data: null이면 크래시
```

### Result Enum 방식 (제안)
```
API → Service (APIResponse<T?>) → Repository
                                      ↓
                          비즈니스 상태로 변환
                          - .loaded(board)
                          - .noHobbyInProgress
                          - .emptyBoard(board)
                                      ↓
                              UseCase → UI
                                      ↓
                          각 케이스별 화면 처리
                          - 스티커판 표시
                          - "취미 없음" Empty State
                          - "스티커 0개" 안내
```

---

## ✅ 장점

1. **디코딩 크래시 방지**: Optional `data`로 안전하게 처리
2. **명확한 상태 구분**: `nil` 대신 enum으로 의미 명확화
   - `nil`은 애매 (에러? 없음? 로딩?)
   - enum은 명확 (`.noHobbyInProgress`)
3. **UI 처리 명확**: 각 상태별로 다른 화면 표시 가능
4. **컴파일 타임 안전성**: switch문으로 모든 케이스 처리 강제
5. **비즈니스 로직 표현력**: 도메인 상태를 타입으로 표현
6. **테스트 용이**: 각 케이스별 테스트 작성 가능
7. **DEBUG 친화적**: 네트워크 에러 시에만 fallback
8. **프로덕션 안전**: 정상 상태는 명확한 UI, 에러는 throw

---

## 📊 패턴 비교표

| 특징 | BaseResponse + toDomain | APIResponse + nil 반환 (문제) | APIResponse + Result Enum (✅ 제안) |
|------|------------------------|----------------------------|--------------------------------|
| **디코딩 안전성** | ❌ `data: null` 시 크래시 | ✅ Optional로 안전 | ✅ Optional로 안전 |
| **상태 명확성** | ⚠️ 단순 모델 반환 | ❌ `nil`의 의미 애매 | ✅ enum으로 명확 |
| **UI 처리** | ⚠️ nil 체크로 분기 | ❌ nil이 뭔지 알 수 없음 | ✅ switch로 각 케이스 처리 |
| **Mock 데이터** | ⚠️ 에러 시 사용 | ❌ 정상 응답에도 사용 (이상함) | ✅ 네트워크 에러에만 사용 |
| **비즈니스 표현** | ⚠️ 모델로만 표현 | ❌ `nil` = 상태 표현 불가 | ✅ enum = 비즈니스 상태 명확 |
| **컴파일 타임 안전성** | ⚠️ nil 체크 누락 가능 | ❌ nil 처리 누락 가능 | ✅ switch 강제 (모든 케이스) |
| **적용 대상** | 단순 API | `data: null` 가능한 API | `data: null` + 상태 분기 필요 |

---

## ⚠️ 고려사항

1. **두 가지 응답 타입 공존**: `BaseResponse` (기존) + `APIResponse` (신규)
   - 혼란 방지를 위해 명확한 가이드 필요
2. **Result enum 증가**: API마다 Result 타입 정의 필요
   - 재사용 가능한 공통 패턴 고려
3. **Repository 복잡도 증가**: 단순 `.toDomain()` 대비 로직 추가
   - 하지만 UI 코드는 더 명확해짐
4. **팀 학습 필요**: 언제 어떤 패턴을 쓸지 가이드 필요
   - 이 문서가 그 가이드 역할

---

## 📌 언제 사용할까?

### ✅ `APIResponse<T?>` + Result Enum 패턴 사용 (이 패턴)

**사용 조건 (하나라도 해당되면 사용)**:
1. 백엔드가 **정상 응답으로 `data: null` 반환**하는 경우
2. `data: null`일 때 **UI가 특정 상태를 보여줘야** 하는 경우
3. 응답에 따라 **여러 비즈니스 상태**로 분기해야 하는 경우

**예시**:
- 스티커판 조회: `data: null` (취미 없음) vs 스티커 0개 vs 스티커 있음
- 활동 목록: `data: null` (취미 없음) vs 활동 0개 vs 활동 있음
- 유저 프로필: `data: null` (탈퇴 유저) vs 정상 유저

### ✅ 기존 `BaseResponse` + `toDomain()` 사용

**사용 조건**:
1. 백엔드가 **항상 유효한 data 반환**하는 경우
2. 단순하고 직관적인 변환만 필요한 경우
3. `data: null`이 **절대 오지 않는** API

**예시**:
- 로그인 응답: 항상 토큰 반환
- 활동 생성 응답: 항상 생성된 데이터 반환
- 설정 변경 응답: 항상 성공 메시지 반환

---

## 🌐 다른 API에도 적용하기

### 적용 체크리스트

다음 질문에 답하며 적용 여부를 판단하세요:

1. **이 API가 정상적으로 `data: null`을 반환하나요?**
   - YES → 이 패턴 고려
   - NO → `BaseResponse` 계속 사용

2. **`data: null`일 때 UI가 특별한 화면을 보여줘야 하나요?**
   - YES → Result enum 필요
   - NO → Optional 반환만으로 충분할 수도

3. **응답에 따라 3개 이상의 UI 상태가 있나요?**
   - YES → Result enum 추천
   - NO → 간단한 Optional 처리로 충분할 수도

### 적용 가능한 후보 API

ForDay 프로젝트에서 이 패턴이 유용할 만한 API:

```swift
// 1. 홈 정보 조회
enum HomeInfoResult {
    case active(HomeInfo)           // 진행 중인 취미 있음
    case noActiveHobby              // data: null
    case completed(HomeInfo)        // 완료된 취미만 있음
}

// 2. 활동 목록 조회
enum ActivityListResult {
    case loaded([Activity])         // 활동 있음
    case noHobbySelected            // 취미 선택 안 됨
    case emptyList                  // 취미는 있지만 활동 0개
}

// 3. AI 추천 (호출 제한)
enum AIRecommendationResult {
    case success(AIRecommendations)
    case limitExceeded(remaining: Int, limit: Int)
    case noHobbyForRecommendation
}
```

### ⚠️ 주의: 오버엔지니어링 피하기

**모든 API에 적용하지 마세요!**

- ❌ 단순 CRUD → `BaseResponse` 충분
- ❌ 항상 data 있음 → 불필요한 복잡도
- ✅ `data: null`이 정상 상태 → 이 패턴 필요

**원칙**: "간단한 것은 간단하게, 복잡한 것만 이 패턴으로"

---

## 🧪 검증 방법

### 기능 테스트

1. **Case 1-3: 정상 데이터**
   - 스티커 1개 이상 → `.loaded(board)` 반환
   - UI에 스티커판 정상 표시

2. **Case 4: `data: null`**
   - `.noHobbyInProgress` 반환
   - UI에 "취미 없음" Empty State 표시
   - ❌ Mock 데이터 표시 안 됨

3. **Case 5: `stickers: []`**
   - `.emptyBoard(board)` 반환
   - UI에 "스티커 0개" 안내 표시
   - 취미 정보는 표시됨

4. **네트워크 에러**
   - DEBUG: fallback 데이터 반환
   - Production: 에러 throw

### 코드 리뷰 체크포인트

- [ ] `switch result`에서 모든 케이스 처리했는가?
- [ ] 각 케이스별로 적절한 UI를 보여주는가?
- [ ] Mock 데이터를 정상 응답에 사용하지 않는가?
- [ ] `data: null`을 에러로 취급하지 않는가?

---

## 📝 구현된 파일 목록

이미 프로토타입이 구현되어 있습니다:

### 신규 파일
- `Source/Data/Network/DTO/Response/GenericAPIResponse.swift`
- `Source/Data/Network/DTO/Response/Activity/StickerBoardResponse.swift`
- `Source/Domain/Entity/Activity/StickerBoard.swift` (내부에 `StickerBoardItem` 구조체 포함)
- `Source/Data/Fallback/StickerBoardFallbackProvider.swift`

> **참고**: 기존 `Sticker` 엔티티 (Presentation/3. ActivityRecord)와 이름 충돌을 피하기 위해 스티커판 API용 엔티티는 `StickerBoardItem`으로 명명했습니다.

### 수정된 파일
- `Source/Domain/RepositoryInterface/ActivityRepositoryInterface.swift` (메서드 1개 추가)
- `Source/Data/Repository/ActivityRepository.swift` (신규 패턴 메서드 추가)
- `Source/Data/Network/TargetType/HobbiesTarget.swift` (케이스 1개 추가)
- `Source/Data/Network/API/Service/ActivityService.swift` (메서드 1개 추가)

---

## 💬 다음 단계

### 1단계: 프로토타입 검증
- [ ] 스티커판 API 실제 연동 테스트
- [ ] 3가지 케이스별 UI 구현
- [ ] 팀 리뷰 및 피드백 수집

### 2단계: 패턴 확정
- [ ] 다른 `data: null` API 목록 정리
- [ ] 적용 우선순위 결정
- [ ] CLAUDE.md에 패턴 가이드 추가

### 3단계: 점진적 적용
```
우선순위 1: 홈 정보 조회 (HomeInfoResult)
우선순위 2: 활동 목록 조회 (ActivityListResult)
우선순위 3: AI 추천 (AIRecommendationResult)
```

### 주의사항

⚠️ **점진적으로 적용하세요**
- 한 번에 모든 API를 바꾸지 마세요
- 하나씩 적용하며 문제 확인
- 팀 합의 후 확산

⚠️ **기존 패턴과 병행**
- `BaseResponse`: 단순 API (대다수)
- `APIResponse<T?>` + Result: 복잡한 상태 분기 필요 시

**참고**: 이 패턴은 "제안"이며 강제 사항이 아닙니다. 프로젝트 상황에 맞게 선택적으로 적용하시면 됩니다.

---

## 💡 실전 팁

### 1. Result enum 네이밍 가이드

```swift
// ✅ Good: 명확한 이름
enum StickerBoardResult { ... }
enum HomeInfoResult { ... }
enum ActivityListResult { ... }

// ❌ Bad: 애매한 이름
enum StickerBoardResponse { ... }  // Response는 DTO 레이어
enum StickerBoardState { ... }     // State는 ViewModel에서 사용
```

### 2. 케이스 네이밍 규칙

```swift
// ✅ Good: 비즈니스 의미 명확
.loaded(data)           // 데이터 있음
.noHobbyInProgress      // 진행 중인 취미 없음
.emptyBoard(info)       // 빈 보드

// ❌ Bad: 기술적 용어
.success(data)          // 모든 케이스가 success
.null                   // 구현 디테일 노출
.none                   // Optional과 혼동
```

### 3. 공통 Result 타입 재사용

여러 API에서 비슷한 패턴이 반복되면 Generic으로:

```swift
enum DataResult<T> {
    case loaded(T)
    case noData(reason: String)
    case empty
}

// 사용
typealias StickerBoardResult = DataResult<StickerBoard>
typealias ActivityListResult = DataResult<[Activity]>
```

### 4. 테스트 작성 예시

```swift
func test_fetchStickerBoard_noHobby_returnsNoHobbyInProgress() async throws {
    // Given
    mockService.stubbedResponse = APIResponse<DTO.StickerBoardDTO>(
        status: 200,
        success: true,
        data: nil
    )

    // When
    let result = try await repository.fetchStickerBoard(...)

    // Then
    guard case .noHobbyInProgress = result else {
        XCTFail("Expected .noHobbyInProgress")
        return
    }
}
```

---

## ❓ FAQ

### Q1. 모든 API를 이 패턴으로 바꿔야 하나요?

**A: 아니요!** `data: null`이 정상 응답인 경우에만 사용하세요.
- 대부분의 API는 `BaseResponse`로 충분합니다
- 오버엔지니어링을 피하세요

### Q2. Result enum vs Optional 반환, 언제 뭘 쓰나요?

**Result enum 사용**:
- UI가 3가지 이상 상태를 보여줘야 할 때
- 비즈니스 로직이 복잡할 때
- 컴파일 타임 안전성이 중요할 때

**Optional 반환**:
- 단순히 있음/없음만 구분할 때
- 케이스가 2개뿐일 때

### Q3. Mock 데이터는 언제 사용하나요?

**Mock 사용 시점**:
- ✅ 네트워크 에러 (개발 중 오프라인)
- ✅ 디코딩 실패 (서버 스펙 변경)
- ✅ SwiftUI Preview
- ❌ `data: null` 정상 응답 (이건 Empty State!)

### Q4. 기존 코드를 한 번에 마이그레이션해야 하나요?

**A: 아니요, 점진적으로!**
1. 새로운 기능부터 이 패턴 적용
2. `data: null` 문제가 발생하는 API만 우선 처리
3. 나머지는 리팩토링 계획에 따라 천천히

### Q5. UseCase도 Result를 반환해야 하나요?

**A: 선택 사항입니다.**

**Repository에서만 Result 사용 (추천)**:
```swift
// Repository
func fetchStickerBoard() -> StickerBoardResult

// UseCase는 그대로 전달
func execute() -> StickerBoardResult
```

**UseCase에서 변환**:
```swift
// Repository
func fetchStickerBoard() -> StickerBoardResult

// UseCase가 다른 형태로 변환
func execute() -> HomeViewState
```

---

## 📝 실제 구현 예시 (스티커판 API)

### Result Enum 정의

```swift
// Domain/Entity/Activity/StickerBoardResult.swift
enum StickerBoardResult {
    case loaded(StickerBoard)
    case noHobbyInProgress
    case emptyBoard(StickerBoard)
}
```

### Repository 구현

```swift
// Data/Repository/ActivityRepository.swift
func fetchStickerBoard(hobbyId: Int?, page: Int?, size: Int?) async throws -> StickerBoardResult {
    do {
        let response = try await activityService.fetchStickerBoard(
            hobbyId: hobbyId,
            page: page,
            size: size
        )

        guard let dto = response.data else {
            return .noHobbyInProgress
        }

        let stickers = dto.stickers?
            .compactMap { item -> StickerBoardItem? in
                guard let id = item.activityRecordId,
                      let sticker = item.sticker else { return nil }
                return StickerBoardItem(activityRecordId: id, sticker: sticker)
            } ?? []

        let board = StickerBoard(
            hobbyId: dto.hobbyId,
            durationSet: dto.durationSet,
            activityRecordedToday: dto.activityRecordedToday,
            currentPage: dto.currentPage,
            totalPage: dto.totalPage,
            pageSize: dto.pageSize,
            totalStickerNum: dto.totalStickerNum,
            hasPrevious: dto.hasPrevious,
            hasNext: dto.hasNext,
            stickers: stickers
        )

        return stickers.isEmpty ? .emptyBoard(board) : .loaded(board)

    } catch {
        #if DEBUG
        print("⚠️ 스티커판 API 네트워크 에러 - fallback 사용")
        return .loaded(fallbackProvider.fallbackStickerBoard())
        #else
        throw error
        #endif
    }
}
```

### ViewModel/ViewController 사용

```swift
// Presentation/2. Home/HomeViewModel.swift
func loadStickerBoard() async {
    isLoading = true

    do {
        let result = try await fetchStickerBoardUseCase.execute()

        await MainActor.run {
            switch result {
            case .loaded(let board):
                self.stickerBoard = board
                self.viewState = .loaded

            case .noHobbyInProgress:
                self.viewState = .emptyState(
                    EmptyStateConfig(
                        icon: "🎯",
                        title: "아직 시작한 취미가 없어요",
                        message: "새로운 취미를 시작해보세요!",
                        actionTitle: "취미 만들기"
                    )
                )

            case .emptyBoard(let board):
                self.stickerBoard = board
                self.viewState = .emptyBoard(
                    message: "첫 활동을 기록하고\n스티커를 채워보세요!"
                )
            }

            self.isLoading = false
        }
    } catch {
        await MainActor.run {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
```
