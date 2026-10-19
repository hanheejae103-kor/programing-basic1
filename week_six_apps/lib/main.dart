import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:async';

void main() {
  runApp(const NoticeApp());
}

class NoticeApp extends StatelessWidget {
  const NoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '6주차 실습 - 비동기 공지 앱',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const NoticePage(),
    );
  }
}

// ==========================================
// 1. Isolate(compute) 계산용 탑레벨 함수
// ==========================================
String parseNoticeInIsolate(int rawCount) {
  int dummyHash = 0;
  for (int i = 0; i < 500000; i++) {
    dummyHash += (i % 7);
  }
  return '📌 [공지] 6주차 비동기 프로그래밍 수강 안내 (데이터 무결성 검증 코드: $dummyHash)';
}

// ==========================================
// 2. 화면 상태 정의 (Enum)
// ==========================================
enum NoticeState { idle, loading, success, failure }

// ==========================================
// 3. 메인 NoticePage
// ==========================================
class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  NoticeState _state = NoticeState.idle;
  String _noticeText = '';
  String _errorMessage = '';
  bool _isLoadingLocked = false;
  bool _simulateError = false;

  late StreamController<int> _countdownController;
  Timer? _timer;
  int _currentCountdown = 5;

  @override
  void initState() {
    super.initState();
    // [핵심 수정!] .broadcast()를 붙여 다중 구독 에러를 방지합니다.
    _countdownController = StreamController<int>.broadcast();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownController.close();
    super.dispose();
  }

  Future<void> fetchNotice() async {
    if (_isLoadingLocked) return;

    setState(() {
      _isLoadingLocked = true;
      _state = NoticeState.loading;
      _errorMessage = '';
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 1));

      if (_simulateError) {
        throw Exception('서버와의 연결이 원활하지 않습니다. (강제 에러)');
      }

      final resultText = await compute(parseNoticeInIsolate, 100);

      if (!mounted) return;

      setState(() {
        _noticeText = resultText;
        _state = NoticeState.success;
      });

      _startCountdownStream();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _state = NoticeState.failure;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocked = false;
        });
      }
    }
  }

  void _startCountdownStream() {
    _timer?.cancel();
    _currentCountdown = 5;

    if (!_countdownController.isClosed) {
      _countdownController.add(_currentCountdown);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentCountdown--;
      if (!_countdownController.isClosed) {
        _countdownController.add(_currentCountdown);
      }

      if (_currentCountdown <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('6주차 실습 - 비동기 공지 앱'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: Colors.indigo.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  '강제 에러 발생 모드 (AC3/AC4 테스트)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _simulateError ? '요청 시 에러가 발생합니다.' : '정상 작동 모드입니다.',
                ),
                value: _simulateError,
                onChanged: (val) {
                  setState(() {
                    _simulateError = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _state == NoticeState.failure
                      ? Colors.red.shade200
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_state == NoticeState.idle) ...[
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 12),
                      const Text('아래 버튼을 눌러 공지사항을 불러오세요.'),
                    ] else if (_state == NoticeState.loading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('공지사항을 불러오는 중입니다...'),
                    ] else if (_state == NoticeState.success) ...[
                      const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _noticeText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),

                      StreamBuilder<int>(
                        stream: _countdownController.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final count = snapshot.data!;
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '⏱ Stream 실시간 알림: $count초 후 공지 자동 갱신 권장',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ] else if (_state == NoticeState.failure) ...[
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoadingLocked ? null : fetchNotice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _state == NoticeState.failure ? '다시 시도 (AC4)' : '공지사항 불러오기',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
