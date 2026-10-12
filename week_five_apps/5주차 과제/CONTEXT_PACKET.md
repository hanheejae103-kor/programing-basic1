# CONTEXT_PACKET: 5주차 할 일 앱 상태 관리 및 컨텍스트

## 1. 목표
- StatefulWidget 및 setState()를 활용하여 완료/취소 상태 토글 기능 구현
- 원본 상태(isDone)에 반응하여 남은 할 일 수(_remainingCount) 동적 계산

## 2. 상태 계약 및 소유자
- **상태 소유자**: `_TaskPageState`
- **원본 상태**: `_tasks` (List<TaskItem> - [false, false])
- **계산된 상태**: `_remainingCount` (get _remainingCount => _tasks.where((task) => !task.isDone).length)
- **이벤트 흐름**: `InkWell.onTap` -> `_toggleTask(index)` -> `setState()` -> `build()` 호출 (UI 리빌드)

## 3. 제약 조건
- 외부 상태관리 패키지(Provider, Bloc 등) 사용 금지
- 서버 및 비동기 기능 미사용 (동기 상태 변경)
- 표시값(_remainingCount) 별도 원본 저장 금지 (AC4)

## 4. 인수 조건 (AC) 검증 결과
- **AC1**: 초기 화면 실행 시 남은 수 2 표시 (확인 완료)
- **AC2**: 완료 버튼 클릭 시 해당 카드 녹색 변경 및 남은 수 1로 변경 (확인 완료)
- **AC3**: 취소 버튼 클릭 시 이전 상태 및 남은 수 2로 복구 (확인 완료)
- **AC4**: _remainingCount를 게터로 처리하여 중복 저장 방지 (확인 완료)