# API 에러 명세

이 문서는 각 API 엔드포인트에서 발생할 수 있는 에러를 정리합니다.

## 공통 에러

모든 API에서 발생 가능한 에러:

| Status | Error Class | Message | 설명 |
|--------|-------------|---------|------|
| 401 | `TOKEN_EXPIRED` | 토큰이 만료되었습니다. | TokenRefreshInterceptor가 자동 처리 |
| 401 | `INVALID_TOKEN` | 유효하지 않은 토큰입니다. | TokenRefreshInterceptor가 자동 처리 |
| 401 | `LOGIN_EXPIRED` | 로그인이 만료되었습니다. | 자동으로 로그인 화면으로 이동 |

---

## Records API

### GET /records/{recordId} - 활동 기록 상세 조회

**성공 응답**: 200
```json
{
  "status": 200,
  "success": true,
  "data": { ... }
}
```

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 404 | `ACTIVITY_RECORD_NOT_FOUND` | 존재하지 않는 활동 기록입니다. | 이전 화면으로 이동 |
| 403 | `FRIEND_ONLY_ACCESS` | 이 글은 친구만 조회할 수 있습니다. | 이전 화면으로 이동 + 권한 없음 메시지 |
| 403 | `PRIVATE_RECORD` | 이 글은 작성자만 볼 수 있습니다. | 이전 화면으로 이동 + 비공개 메시지 |

**구현 위치**: `ActivityDetailViewController.handleError()`

---

## Activities API

### GET /hobbies/{hobbyId}/activities/list - 활동 목록 조회

**성공 응답**: 200

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 404 | `HOBBY_NOT_FOUND` | 존재하지 않는 취미입니다. | 에러 메시지 표시 + 홈으로 이동 |

**구현 위치**: `ActivityListViewController.handleError()`

### POST /hobbies/{hobbyId}/activities - 활동 생성

**성공 응답**: 201

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 400 | `INVALID_ACTIVITY_NAME` | 활동 이름이 유효하지 않습니다. | 에러 메시지 표시 + 입력 필드 포커스 |
| 400 | `DUPLICATE_ACTIVITY` | 이미 존재하는 활동입니다. | 에러 메시지 표시 |
| 404 | `HOBBY_NOT_FOUND` | 존재하지 않는 취미입니다. | 에러 메시지 표시 + 이전 화면 |

**구현 위치**: `HobbyActivityInputViewController.handleError()`

### PUT /activities/{activityId} - 활동 수정

**성공 응답**: 200

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 404 | `ACTIVITY_NOT_FOUND` | 존재하지 않는 활동입니다. | 에러 메시지 표시 + 목록 새로고침 |
| 403 | `NOT_ACTIVITY_OWNER` | 수정 권한이 없습니다. | 에러 메시지 표시 |

**구현 위치**: `ActivityListViewController.handleError()`

### DELETE /activities/{activityId} - 활동 삭제

**성공 응답**: 200

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 404 | `ACTIVITY_NOT_FOUND` | 존재하지 않는 활동입니다. | 에러 메시지 표시 + 목록 새로고침 |
| 403 | `NOT_ACTIVITY_OWNER` | 삭제 권한이 없습니다. | 에러 메시지 표시 |
| 400 | `ACTIVITY_NOT_DELETABLE` | 삭제할 수 없는 활동입니다. | 서버 메시지 표시 |

**구현 위치**: `ActivityListViewController.handleError()`

---

## Users API

### GET /users/feeds - 사용자 피드 목록 조회

**성공 응답**: 200

**에러 응답**:

| Status | Error Class | Message | 대응 방법 |
|--------|-------------|---------|----------|
| 404 | `USER_NOT_FOUND` | 사용자를 찾을 수 없습니다. | 로그아웃 처리 |

**구현 위치**: `MyPageViewController.handleError()`

---

## 에러 추가 프로세스

새로운 API를 추가할 때:

1. **서버 문서 확인** - API 명세에서 가능한 에러 확인
2. **이 문서에 기록** - 표 형식으로 정리
3. **필요시 코드 구현** - 특별한 처리가 필요한 경우만
   - 일반적인 에러: 서버 메시지 그대로 표시
   - 특수한 에러: ViewController에 커스텀 처리 추가

## 참고

- 대부분의 에러는 **서버가 보낸 메시지를 그대로 표시**하면 됨
- **특별한 액션이 필요한 경우**만 ViewController에 switch-case 추가
  - 예: 화면 이동, 로그아웃, 특정 UI 업데이트
- 모든 에러를 코드로 정의할 필요 없음 (오버엔지니어링 방지)
