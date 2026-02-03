# iOS 에러 처리 완벽 가이드

## 목차

1. [Swift 에러 처리 기초](#1-swift-에러-처리-기초)
2. [iOS 앱의 에러 처리 레이어](#2-ios-앱의-에러-처리-레이어)
3. [네트워킹 에러 처리](#3-네트워킹-에러-처리)
4. [사용자에게 에러 표시하기](#4-사용자에게-에러-표시하기)
5. [ForDay 프로젝트의 에러 처리](#5-forday-프로젝트의-에러-처리)
6. [실무 베스트 프랙티스](#6-실무-베스트-프랙티스)
7. [더 공부하기](#7-더-공부하기)

---

## 1. Swift 에러 처리 기초

### 1.1 Error Protocol

Swift에서 에러는 `Error` 프로토콜을 채택한 타입으로 표현됩니다.

```swift
// 가장 기본적인 에러 정의
enum NetworkError: Error {
    case noConnection
    case timeout
    case serverError
}
```

### 1.2 에러 던지기 (throw)

함수가 에러를 던질 수 있다면 `throws` 키워드를 사용합니다.

```swift
func fetchData() throws -> Data {
    guard isConnected else {
        throw NetworkError.noConnection
    }

    // 데이터 가져오기
    return data
}
```

### 1.3 에러 잡기 (do-catch)

```swift
do {
    let data = try fetchData()
    print("성공: \(data)")
} catch NetworkError.noConnection {
    print("인터넷 연결 없음")
} catch NetworkError.timeout {
    print("시간 초과")
} catch {
    print("알 수 없는 에러: \(error)")
}
```

### 1.4 try 변형들

```swift
// try: 에러를 상위로 전달
func process() throws {
    let data = try fetchData()  // 에러가 발생하면 process()도 throw
}

// try?: 에러 발생 시 nil 반환
let data = try? fetchData()  // Data? (실패하면 nil)

// try!: 에러가 없다고 확신할 때 (위험!)
let data = try! fetchData()  // 에러 발생 시 크래시
```

### 1.5 Result 타입

Swift 5부터는 `Result` 타입으로 성공/실패를 명시적으로 표현할 수 있습니다.

```swift
enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

// 사용 예시
func fetchUser(completion: @escaping (Result<User, NetworkError>) -> Void) {
    // ...
}

fetchUser { result in
    switch result {
    case .success(let user):
        print("사용자: \(user.name)")
    case .failure(let error):
        print("에러: \(error)")
    }
}
```

---

## 2. iOS 앱의 에러 처리 레이어

### 2.1 Clean Architecture에서의 에러 흐름

```
UI Layer (ViewController)
    ↓ 에러를 사용자에게 표시
Presentation Layer (ViewModel)
    ↓ 에러를 UI 친화적으로 변환
Domain Layer (UseCase)
    ↓ 비즈니스 로직 에러 처리
Data Layer (Repository)
    ↓ 데이터 소스 에러 처리
Network/Database Layer
    ↓ 실제 에러 발생
```

### 2.2 각 레이어의 책임

**Network Layer**
- HTTP 상태 코드 처리
- 네트워크 연결 에러
- 타임아웃 처리
- 응답 파싱 실패

**Data Layer (Repository)**
- 네트워크 에러를 도메인 에러로 변환
- 데이터 검증
- 캐시 실패 처리

**Domain Layer (UseCase)**
- 비즈니스 규칙 검증
- 여러 데이터 소스의 에러 조합
- 도메인 특화 에러 생성

**Presentation Layer (ViewModel)**
- 에러를 UI 친화적인 메시지로 변환
- 에러 상태 관리 (@Published)
- 재시도 로직

**UI Layer (ViewController)**
- 에러를 사용자에게 표시
- 적절한 UI 액션 제공 (재시도, 취소 등)

---

## 3. 네트워킹 에러 처리

### 3.1 일반적인 네트워크 에러 타입

```swift
enum NetworkError: Error {
    // 연결 문제
    case noInternet          // 인터넷 연결 없음
    case timeout             // 요청 시간 초과
    case serverNotReachable  // 서버 접근 불가

    // HTTP 에러
    case unauthorized        // 401
    case forbidden           // 403
    case notFound            // 404
    case serverError         // 500

    // 데이터 에러
    case invalidResponse     // 응답 형식이 잘못됨
    case decodingFailed      // JSON 파싱 실패

    // 기타
    case unknown
}
```

### 3.2 HTTP 상태 코드 처리

```swift
func handleResponse(_ response: HTTPURLResponse) throws {
    switch response.statusCode {
    case 200...299:
        // 성공
        return

    case 400...499:
        // 클라이언트 에러
        switch response.statusCode {
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.clientError(response.statusCode)
        }

    case 500...599:
        // 서버 에러
        throw NetworkError.serverError

    default:
        throw NetworkError.unknown
    }
}
```

### 3.3 서버 에러 메시지 파싱

대부분의 API는 에러 정보를 JSON으로 반환합니다:

```json
{
  "status": 404,
  "success": false,
  "data": {
    "errorClassName": "USER_NOT_FOUND",
    "message": "사용자를 찾을 수 없습니다."
  }
}
```

```swift
struct ServerErrorResponse: Decodable {
    let status: Int
    let success: Bool
    let data: ErrorData

    struct ErrorData: Decodable {
        let errorClassName: String
        let message: String
    }
}

// 파싱 예시
do {
    let errorResponse = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
    // 서버가 제공한 메시지를 사용자에게 표시
    showError(errorResponse.data.message)
} catch {
    // 파싱 실패 - 기본 메시지 사용
    showError("알 수 없는 오류가 발생했습니다.")
}
```

### 3.4 URLError 처리

Foundation의 `URLError`는 네트워크 관련 다양한 에러를 제공합니다:

```swift
func convertURLError(_ error: URLError) -> NetworkError {
    switch error.code {
    case .notConnectedToInternet, .networkConnectionLost:
        return .noInternet
    case .timedOut:
        return .timeout
    case .cannotFindHost, .cannotConnectToHost:
        return .serverNotReachable
    case .cancelled:
        return .cancelled
    default:
        return .unknown
    }
}
```

---

## 4. 사용자에게 에러 표시하기

### 4.1 UIAlertController (기본)

가장 간단한 방법:

```swift
func showError(_ message: String) {
    let alert = UIAlertController(
        title: "오류",
        message: message,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
}
```

### 4.2 에러 타입별 다른 UI

```swift
func handleError(_ error: AppError) {
    switch error {
    case .network(let networkError):
        // 네트워크 에러 - 재시도 버튼 제공
        showRetryAlert(message: networkError.userMessage) {
            self.retryLastOperation()
        }

    case .server(let serverError):
        // 서버 에러 - 에러 타입에 따라 다른 처리
        if serverError.statusCode == 404 {
            // 리소스를 찾을 수 없음 - 이전 화면으로
            navigationController?.popViewController(animated: true)
        } else {
            // 일반 서버 에러
            showError(serverError.message)
        }

    case .decoding:
        // 개발 단계에서만 보여줄 에러
        #if DEBUG
        showError("데이터 형식 오류 (개발용)")
        #else
        showError("일시적인 오류가 발생했습니다.")
        #endif

    case .unknown:
        showError("알 수 없는 오류가 발생했습니다.")
    }
}

func showRetryAlert(message: String, retry: @escaping () -> Void) {
    let alert = UIAlertController(
        title: "네트워크 오류",
        message: message,
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in
        retry()
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
    present(alert, animated: true)
}
```

### 4.3 Toast 메시지 (비중요 에러용)

```swift
class ToastView: UIView {
    static func show(message: String, in viewController: UIViewController) {
        let toast = ToastView()
        // ... 토스트 UI 구성

        viewController.view.addSubview(toast)

        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        })
    }
}

// 사용
ToastView.show(message: "네트워크 연결이 불안정합니다", in: self)
```

### 4.4 Empty State View (데이터 없을 때)

```swift
class EmptyStateView: UIView {
    func configure(for errorType: AppError) {
        switch errorType {
        case .network(.noInternet):
            imageView.image = UIImage(named: "no_wifi")
            titleLabel.text = "인터넷 연결 없음"
            messageLabel.text = "Wi-Fi 또는 모바일 데이터를 확인해주세요"
            actionButton.setTitle("다시 시도", for: .normal)

        case .server(.notFound):
            imageView.image = UIImage(named: "empty_box")
            titleLabel.text = "데이터를 찾을 수 없습니다"
            messageLabel.text = nil
            actionButton.isHidden = true

        default:
            imageView.image = UIImage(named: "error")
            titleLabel.text = "오류 발생"
            messageLabel.text = "잠시 후 다시 시도해주세요"
            actionButton.setTitle("다시 시도", for: .normal)
        }
    }
}
```

---

## 5. ForDay 프로젝트의 에러 처리

### 5.1 구조 개요

```
AppError (통합 에러 타입)
├── NetworkError (네트워크 문제)
├── ServerError (서버 에러)
├── DecodingError (파싱 실패)
└── Unknown (기타)
```

### 5.2 자동 에러 파싱

`MoyaProvider+Async` extension이 모든 네트워크 요청의 에러를 자동으로 처리:

```swift
extension MoyaProvider {
    func request<T: Decodable>(_ target: Target) async throws -> T {
        // 1. 요청 실행
        // 2. 에러 상태 코드 확인 (400~599)
        // 3. 서버 에러 응답 파싱 시도
        // 4. AppError로 변환
        // 5. 성공 시 데이터 디코딩
    }
}
```

**장점**:
- 모든 API 호출에서 일관된 에러 처리
- 보일러플레이트 코드 감소
- 서버 메시지 자동 추출

### 5.3 ViewModel 패턴

```swift
class MyViewModel {
    @Published var error: AppError?  // Combine으로 ViewController에 전달

    func fetchData() async {
        do {
            let data = try await useCase.execute()
            // 성공 처리
        } catch let appError as AppError {
            // AppError로 캐치된 경우
            await MainActor.run {
                self.error = appError
            }
        } catch {
            // 그 외의 에러
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }
}
```

**왜 MainActor.run을 사용하나요?**
- `@Published` 프로퍼티는 메인 스레드에서 업데이트해야 함
- `async` 함수는 백그라운드에서 실행될 수 있음
- `MainActor.run`으로 메인 스레드 보장

### 5.4 ViewController 패턴

```swift
class MyViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        viewModel.$error
            .receive(on: DispatchQueue.main)  // 메인 스레드 보장
            .compactMap { $0 }                // nil 제거
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: AppError) {
        // 에러 타입별 처리
    }
}
```

**Combine 흐름**:
1. ViewModel의 `error` 프로퍼티가 변경됨
2. `$error` Publisher가 이벤트 발행
3. `receive(on:)` - 메인 스레드로 전환
4. `compactMap` - nil 값 필터링
5. `sink` - 에러 처리 함수 실행
6. `store(in:)` - 구독 유지

---

## 6. 실무 베스트 프랙티스

### 6.1 DO ✅

**1. 에러 타입을 계층적으로 구성하기**
```swift
enum AppError: Error {
    case network(NetworkError)
    case business(BusinessError)
    case database(DatabaseError)
}
```

**2. 사용자 친화적인 메시지 제공**
```swift
var userMessage: String {
    switch self {
    case .network(.noInternet):
        return "인터넷 연결을 확인해주세요."
    case .network(.timeout):
        return "요청 시간이 초과되었습니다.\n잠시 후 다시 시도해주세요."
    }
}
```

**3. 서버가 보낸 에러 메시지 활용**
```swift
// 서버: "이미 사용 중인 닉네임입니다."
// 그대로 사용자에게 표시 ✅
showError(serverError.message)
```

**4. 로깅 추가**
```swift
catch {
    print("❌ 에러 발생: \(error)")
    print("📍 위치: \(#function), 파일: \(#file), 라인: \(#line)")
    self.error = .unknown(error)
}
```

**5. 재시도 로직 제공**
```swift
case .network:
    showAlert(
        title: "네트워크 오류",
        message: error.userMessage,
        actions: [
            ("다시 시도", { self.retry() }),
            ("취소", nil)
        ]
    )
```

### 6.2 DON'T ❌

**1. error.localizedDescription 남용하지 않기**
```swift
// ❌ 나쁜 예
showError(error.localizedDescription)
// "The data couldn't be read because it is missing."

// ✅ 좋은 예
showError(error.userMessage)
// "데이터를 불러올 수 없습니다."
```

**2. 에러 무시하지 않기**
```swift
// ❌ 절대 하지 말 것
do {
    try riskyOperation()
} catch {
    // 아무것도 안 함
}

// ✅ 최소한 로그는 남기기
do {
    try riskyOperation()
} catch {
    print("⚠️ 에러 발생했으나 무시: \(error)")
}
```

**3. try! 남용하지 않기**
```swift
// ❌ 위험 - 에러 발생 시 크래시
let data = try! JSONDecoder().decode(User.self, from: data)

// ✅ 안전
do {
    let user = try JSONDecoder().decode(User.self, from: data)
} catch {
    print("파싱 실패: \(error)")
}
```

**4. 모든 에러를 Alert로 표시하지 않기**
```swift
// ❌ 사용자 경험 나쁨
viewModel.$error.sink { error in
    self.showAlert(error.message)  // 모든 에러가 Alert
}

// ✅ 에러 타입에 따라 다르게
viewModel.$error.sink { error in
    switch error.severity {
    case .critical:
        self.showAlert(error.message)
    case .warning:
        self.showToast(error.message)
    case .info:
        print("ℹ️ \(error.message)")
    }
}
```

**5. 에러 메시지에 기술 용어 사용하지 않기**
```swift
// ❌ 사용자가 이해하기 어려움
"HTTP 500 Internal Server Error"
"JSON decoding failed at keyPath 'user.name'"

// ✅ 사용자 친화적
"일시적인 오류가 발생했습니다."
"사용자 정보를 불러올 수 없습니다."
```

### 6.3 에러 복구 전략

**1. 자동 재시도**
```swift
func fetchWithRetry(maxRetries: Int = 3) async throws -> Data {
    var lastError: Error?

    for attempt in 1...maxRetries {
        do {
            return try await fetch()
        } catch {
            lastError = error
            print("재시도 \(attempt)/\(maxRetries)")
            try await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(attempt))
        }
    }

    throw lastError!
}
```

**2. Fallback 데이터**
```swift
func fetchUser() async -> User {
    do {
        return try await repository.fetchUser()
    } catch {
        print("⚠️ API 실패, 캐시 사용")
        return cache.getUser() ?? User.guest  // Fallback
    }
}
```

**3. Graceful Degradation**
```swift
// 일부 기능이 실패해도 앱은 계속 동작
do {
    let profile = try await fetchProfile()
    let posts = try await fetchPosts()
    show(profile: profile, posts: posts)
} catch {
    // 프로필만이라도 보여주기
    if let profile = try? await fetchProfile() {
        show(profile: profile, posts: [])
    } else {
        showError()
    }
}
```

---

## 7. 더 공부하기

### 7.1 Swift 공식 문서
- [Error Handling](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html)
- [Result](https://developer.apple.com/documentation/swift/result)

### 7.2 애플 WWDC 세션
- [WWDC 2021: What's new in Swift](https://developer.apple.com/videos/play/wwdc2021/10192/)
- [WWDC 2019: Modern Swift API Design](https://developer.apple.com/videos/play/wwdc2019/415/)

### 7.3 고급 주제

**Async/Await의 에러 처리**
```swift
// 여러 비동기 작업의 에러 처리
async let user = fetchUser()
async let posts = fetchPosts()
async let comments = fetchComments()

do {
    let (u, p, c) = try await (user, posts, comments)
    // 모두 성공
} catch {
    // 하나라도 실패하면 여기로
}
```

**TaskGroup으로 병렬 처리**
```swift
await withThrowingTaskGroup(of: User.self) { group in
    for id in userIds {
        group.addTask {
            try await fetchUser(id)
        }
    }

    do {
        for try await user in group {
            users.append(user)
        }
    } catch {
        print("에러 발생: \(error)")
        group.cancelAll()
    }
}
```

**Custom Error 확장**
```swift
enum ValidationError: LocalizedError {
    case tooShort(fieldName: String, minLength: Int)
    case invalidFormat(fieldName: String)

    var errorDescription: String? {
        switch self {
        case .tooShort(let field, let min):
            return "\(field)는 최소 \(min)자 이상이어야 합니다."
        case .invalidFormat(let field):
            return "\(field)의 형식이 올바르지 않습니다."
        }
    }
}
```

### 7.4 실습 과제

**Level 1: 기초**
1. 간단한 에러 enum 만들기
2. do-catch로 에러 처리하기
3. Result 타입 사용해보기

**Level 2: 중급**
1. 네트워크 요청 에러 처리 구현
2. ViewModel에 에러 상태 추가
3. UIAlertController로 에러 표시

**Level 3: 고급**
1. 계층적 에러 시스템 설계
2. 자동 재시도 로직 구현
3. 커스텀 에러 뷰 만들기

---

## 요약

**에러 처리의 핵심**:
1. ✅ **에러를 예상하고 처리하라** - 모든 네트워크 요청은 실패할 수 있다
2. ✅ **사용자에게 명확하게 알려라** - "뭔가 잘못됐어요" 대신 구체적인 메시지
3. ✅ **복구 방법을 제공하라** - 재시도, 취소 등의 옵션
4. ✅ **로깅을 남겨라** - 디버깅과 모니터링을 위해
5. ✅ **계층별로 책임을 나눠라** - Network → Data → Domain → Presentation → UI

**ForDay 프로젝트에서**:
- `AppError`로 통합된 에러 타입
- `MoyaProvider+Extension`으로 자동 파싱
- ViewModel에서 `@Published var error: AppError?`
- ViewController에서 에러 타입별 UI 처리

이제 에러 처리를 자신있게 할 수 있을 거예요! 🚀
