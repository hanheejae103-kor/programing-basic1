import 'package:flutter/material.dart';

void main() {
  runApp(const NoticeApp());
}

class NoticeApp extends StatelessWidget {
  const NoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '공지사항 앱',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const NoticePage(),
    );
  }
}

/// 공지사항 데이터 모델
class NoticeItem {
  final String title;
  final String content;
  final String date;
  bool isRead;

  NoticeItem({
    required this.title,
    required this.content,
    required this.date,
    this.isRead = false,
  });
}

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  // 공지사항 데이터 목록
  final List<NoticeItem> _notices = [
    NoticeItem(
      title: '📢 [공지] 2026학년도 2학기 강의실 변경 안내',
      content: '컴퓨터소프트웨어학과 6주차 실습 수업은 302호 실습실에서 진행됩니다.',
      date: '2026.10.19',
    ),
    NoticeItem(
      title: '📌 [안내] 중간고사 기간 및 평가 기준 공지',
      content: '중간고사 실습 과제 제출 기한은 7주차 수업 전까지입니다.',
      date: '2026.10.15',
    ),
    NoticeItem(
      title: '🎉 [행사] 학과 소프트웨어 경진대회 개최',
      content: '학생 여러분의 많은 참여 바랍니다. 상금 및 수료증이 지급됩니다.',
      date: '2026.10.10',
    ),
  ];

  // 안 읽은 공지 개수 계산 (게터)
  int get _unreadCount => _notices.where((notice) => !notice.isRead).length;

  // 읽음 처리 토글 함수
  void _toggleRead(int index) {
    setState(() {
      _notices[index].isRead = !_notices[index].isRead;
    });
  }

  // 모두 읽음 처리 함수
  void _markAllAsRead() {
    setState(() {
      for (var notice in _notices) {
        notice.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('학과 공지사항'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                '모두 읽음',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 상단 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.shade100),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.indigo,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _unreadCount > 0
                          ? '읽지 않은 새 공지가 $_unreadCount건 있습니다.'
                          : '모든 공지를 확인했습니다!',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 공지 목록
            Expanded(
              child: ListView.separated(
                itemCount: _notices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notice = _notices[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: notice.isRead
                            ? const Color(0xFFE2E8F0)
                            : Colors.indigo.shade200,
                        width: notice.isRead ? 1 : 2,
                      ),
                    ),
                    color: notice.isRead
                        ? Colors.white
                        : const Color(0xFFEEF2FF),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _toggleRead(index),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notice.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: notice.isRead
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (!notice.isRead)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notice.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notice.date,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  notice.isRead ? '읽음' : '터치하여 읽음 표시',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: notice.isRead
                                        ? const Color(0xFF94A3B8)
                                        : Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
