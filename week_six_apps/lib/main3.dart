import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:async';

void main() {
  runApp(const HipStudyApp());
}

class HipStudyApp extends StatelessWidget {
  const HipStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '스마트 학과 공지 & 족보 메이트',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Pretendard',
      ),
      home: const NoticePage(),
    );
  }
}

// [Isolate/compute] 백그라운드 데이터 파싱
String parseNoticeInIsolate(String rawData) {
  int dummyHash = 0;
  for (int i = 0; i < 300000; i++) {
    dummyHash += (i % 7);
  }
  return '$rawData (검증코드: $dummyHash)';
}

/// [도메인 모델] 스터디 메이트 게시글
class NoticeItem {
  final String id;
  String title;
  String category;
  String content;
  String author;
  String date;
  bool isRead;
  bool isBookmarked;
  String? attachedFileName;
  int? attachedFileSize;
  Map<String, int> reactions;
  String? userReaction;
  List<String> comments;

  int maxMembers;
  int currentMembers;
  bool isJoined;

  NoticeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.date,
    this.isRead = false,
    this.isBookmarked = false,
    this.attachedFileName,
    this.attachedFileSize,
    Map<String, int>? reactions,
    this.userReaction,
    List<String>? comments,
    this.maxMembers = 4,
    this.currentMembers = 1,
    this.isJoined = false,
  }) : reactions = reactions ?? {'❤️': 0, '💡': 0, '🔥': 0, '😢': 0},
       comments = comments ?? [];

  bool get isStudyFull => currentMembers >= maxMembers;
}

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final List<NoticeItem> _notices = [
    NoticeItem(
      id: '1',
      category: '🔥 시험족보',
      title: '📖 [컴퓨터 구조] 중간고사 핵심 예상 문제 & 개념 요약집',
      content: '1. 파이프라인 데이터 해저드 해결 방법 3가지\n2. 캐시 메모리 사상 방식\n3. ALU 버스 구조 요약\n\n첨부된 PDF 요약집 보고 모두 A+ 받아가세요! 🚀',
      author: 'A+학점사냥꾼',
      date: '2026.10.19',
      attachedFileName: '컴퓨터구조_중간고사_요약집.pdf',
      attachedFileSize: 2450,
      reactions: {'❤️': 24, '💡': 42, '🔥': 58, '😢': 2},
      comments: ['와 퀄리티 미쳤네요!', 'PDF 잘 다운받아집니다 고맙습니다🔥'],
    ),
    NoticeItem(
      id: '2',
      category: '✏️ 스터디모집',
      title: '💻 [플러터 프로그래밍] 6주차 비동기 과제 정복 스터디원 모집 (2명)',
      content: 'Stream, Isolate, Future 개념이 어려우신 분들 같이 모여서 실습 과제 리뷰하고 족보 공유해요! 매주 목요일 도서관 스터디룸에서 진행합니다.',
      author: '코딩장인',
      date: '2026.10.18',
      maxMembers: 4,
      currentMembers: 2,
      reactions: {'❤️': 12, '💡': 18, '🔥': 30, '😢': 0},
      comments: ['참여 신청했습니다!', '장소 변경 가능할까요?'],
    ),
  ];

  String _selectedCategory = '전체';
  String _searchQuery = '';

  late final StreamController<int> _timerController;
  Timer? _timer;
  int _secondsLeft = 3600;

  @override
  void initState() {
    super.initState();
    _timerController = StreamController<int>.broadcast();
    _startLiveTimerStream();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.close();
    super.dispose();
  }

  void _startLiveTimerStream() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        if (!_timerController.isClosed) {
          _timerController.add(_secondsLeft);
        }
      } else {
        timer.cancel();
      }
    });
  }

  List<NoticeItem> get _filteredNotices {
    return _notices.where((notice) {
      final matchesCategory =
          (_selectedCategory == '전체') ||
          (_selectedCategory == '🔖 보관함'
              ? notice.isBookmarked
              : notice.category == _selectedCategory);
      final matchesSearch =
          notice.title.contains(_searchQuery) ||
          notice.content.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _unreadCount => _notices.where((n) => !n.isRead).length;

  Future<void> _downloadFileAsync(String fileName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⏳ $fileName 다운로드 요청 중... (Future 대기)')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('✅ $fileName 다운로드가 완료되었습니다! 🚀')));
  }

  void _deleteNotice(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          '삭제 확인',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '해당 게시글을 정말 삭제하시겠습니까?',
          style: TextStyle(color: Color(0xFFE5E7EB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _notices.removeWhere((item) => item.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _selectSingleReaction(
    NoticeItem notice,
    String selectedEmoji,
    StateSetter setDialogState,
  ) {
    setDialogState(() {
      if (notice.userReaction == selectedEmoji) {
        notice.reactions[selectedEmoji] =
            (notice.reactions[selectedEmoji] ?? 1) - 1;
        notice.userReaction = null;
      } else {
        if (notice.userReaction != null) {
          final previousEmoji = notice.userReaction!;
          notice.reactions[previousEmoji] =
              (notice.reactions[previousEmoji] ?? 1) - 1;
        }
        notice.userReaction = selectedEmoji;
        notice.reactions[selectedEmoji] =
            (notice.reactions[selectedEmoji] ?? 0) + 1;
      }
    });
    setState(() {});
  }

  void _toggleStudyJoin(NoticeItem notice, StateSetter setDialogState) {
    setDialogState(() {
      if (notice.isJoined) {
        notice.isJoined = false;
        notice.currentMembers--;
      } else {
        if (!notice.isStudyFull) {
          notice.isJoined = true;
          notice.currentMembers++;
        }
      }
    });
    setState(() {});
  }

  void _showNoticeDetail(int index) {
    final notice = _filteredNotices[index];
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
              ),
              child: SizedBox(
                width: 480,
                height: 620,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notice.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  notice.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setDialogState(
                                    () => notice.isBookmarked =
                                        !notice.isBookmarked,
                                  );
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deleteNotice(notice.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() => notice.isRead = true);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notice.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '작성자: ${notice.author}  |  ${notice.date}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                            const Divider(color: Color(0xFF1F2937), height: 24),
                            Text(
                              notice.content,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (notice.category == '✏️ 스터디모집') ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '스터디 현황: ${notice.currentMembers} / ${notice.maxMembers}명',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          notice.isStudyFull
                                              ? '상태: 모집 완료'
                                              : '상태: 모집 중 🚀',
                                          style: TextStyle(
                                            color: notice.isStudyFull
                                                ? Colors.redAccent
                                                : Colors.tealAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: notice.isJoined
                                            ? Colors.redAccent
                                            : const Color(0xFF10B981),
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed:
                                          (notice.isStudyFull &&
                                              !notice.isJoined)
                                          ? null
                                          : () => _toggleStudyJoin(
                                              notice,
                                              setDialogState,
                                            ),
                                      child: Text(
                                        notice.isJoined ? '신청 취소' : '스터디 참여하기',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (notice.attachedFileName != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF06B6D4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      color: Color(0xFFF43F5E),
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notice.attachedFileName!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${(notice.attachedFileSize! / 1024).toStringAsFixed(2)} MB',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () => _downloadFileAsync(
                                        notice.attachedFileName!,
                                      ),
                                      child: const Text(
                                        '다운로드 (Future)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            const Text(
                              '공감 스티커 (하나만 선택)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: notice.reactions.keys.map((emoji) {
                                final isSelected = notice.userReaction == emoji;
                                return FilterChip(
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF06B6D4),
                                  backgroundColor: const Color(0xFF1F2937),
                                  label: Text(
                                    '$emoji ${notice.reactions[emoji]}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                  onSelected: (_) => _selectSingleReaction(
                                    notice,
                                    emoji,
                                    setDialogState,
                                  ),
                                );
                              }).toList(),
                            ),
                            const Divider(color: Color(0xFF1F2937), height: 32),

                            const Text(
                              '💬 실시간 Q&A 및 댓글',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...notice.comments.map(
                              (c) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '💬 $c',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: '댓글 작성...',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Color(0xFF1F2937),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0284C7),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (commentController.text
                                        .trim()
                                        .isNotEmpty) {
                                      setDialogState(() {
                                        notice.comments.add(
                                          commentController.text.trim(),
                                        );
                                        commentController.clear();
                                      });
                                      setState(() {});
                                    }
                                  },
                                  child: const Text('등록'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNoticeDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = '🔥 시험족보';
    String? selectedFileName;
    int? selectedFileSize;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF111827),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: SizedBox(
                width: 480,
                height: 520,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚀 새 족보 / 스터디 모집 작성',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                dropdownColor: const Color(0xFF1F2937),
                                style: const TextStyle(color: Colors.white),
                                items: ['🔥 시험족보', '📢 강의공지', '✏️ 스터디모집']
                                    .map(
                                      (cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) => selectedCategory = val!,
                                decoration: const InputDecoration(
                                  labelText: '카테고리',
                                ),
                              ),
                              TextField(
                                controller: titleController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: '제목',
                                ),
                              ),
                              TextField(
                                controller: contentController,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: '내용',
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.attach_file),
                                label: Text(
                                  selectedFileName ?? '📂 PDF / 족보 파일 선택',
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedFileName = '2026_중간고사_족보_A플.pdf';
                                    selectedFileSize = 1850;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              if (titleController.text.isNotEmpty &&
                                  contentController.text.isNotEmpty) {
                                final parsedContent = await compute(
                                  parseNoticeInIsolate,
                                  contentController.text,
                                );

                                setState(() {
                                  _notices.insert(
                                    0,
                                    NoticeItem(
                                      id: DateTime.now().toString(),
                                      title: titleController.text,
                                      category: selectedCategory,
                                      content: parsedContent,
                                      author: '나(학부생)',
                                      date: '2026.10.19',
                                      attachedFileName: selectedFileName,
                                      attachedFileSize: selectedFileSize,
                                    ),
                                  );
                                });
                                if (mounted) Navigator.pop(context);
                              }
                            },
                            child: const Text('게시하기 (Isolate)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          '👤 내 프로필 & 스터디 정보',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('닉네임: 나(학부생)', style: TextStyle(color: Colors.white)),
            const Text(
              '전공: 컴퓨터소프트웨어학과 (3학년)',
              style: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            const Divider(color: Color(0xFF1F2937), height: 20),
            Text(
              '내가 등록한 족보: ${_notices.where((n) => n.author == '나(학부생)').length}개',
              style: const TextStyle(color: Color(0xFF22D3EE)),
            ),
            Text(
              '보관함 저장 항목: ${_notices.where((n) => n.isBookmarked).length}개',
              style: const TextStyle(color: Color(0xFF10B981)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0369A1), Color(0xFF0F766E)],
            ),
          ),
        ),
        title: const Text(
          '⚡ STUDY MATE PLATFORM',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '중간고사 열공 모드 가동 중!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: _timerController.stream,
                        builder: (context, snapshot) {
                          final seconds = snapshot.data ?? 3600;
                          final m = (seconds ~/ 60).toString().padLeft(2, '0');
                          final s = (seconds % 60).toString().padLeft(2, '0');
                          return Text(
                            '⏱️ Stream 실시간 남은 시험시간: $m분 $s초 (미확인: $_unreadCount건)',
                            style: const TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔍 [수정 핵심 부분] ChoiceChip 대신 Custom 탭 스타일을 사용하여 텍스트가 절대 잘리지 않음
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: '족보, 과목명, 스터디 검색...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF06B6D4),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1F2937),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['전체', '🔥 시험족보', '📢 강의공지', '✏️ 스터디모집', '🔖 보관함']
                        .map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ), // 여유있는 패딩
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF1F2937),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF374151),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : const Color(0xFFE5E7EB),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredNotices.length,
              itemBuilder: (context, index) {
                final notice = _filteredNotices[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: notice.isRead
                        ? const Color(0xFF111827)
                        : const Color(0xFF1E293B),
                    border: Border.all(
                      color: notice.isRead
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF06B6D4),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Text(
                          notice.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22D3EE),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (notice.category == '✏️ 스터디모집')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notice.isStudyFull
                                  ? Colors.redAccent
                                  : Colors.teal,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              notice.isStudyFull
                                  ? '마감'
                                  : '${notice.currentMembers}/${notice.maxMembers}명',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            notice.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => notice.isBookmarked = !notice.isBookmarked,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: notice.isRead
                                ? const Color(0xFF9CA3AF)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${notice.author} • ${notice.date}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '❤️ ${notice.reactions['❤️']}  💬 ${notice.comments.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF22D3EE),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _showNoticeDetail(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoticeDialog,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit_note_rounded, size: 28),
        label: const Text(
          '족보/스터디 작성',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
