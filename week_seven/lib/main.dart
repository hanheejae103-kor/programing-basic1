import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'word_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LectureWordApp());
}

class LectureWordApp extends StatelessWidget {
  const LectureWordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '수업 단어 메모장',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
      ),
      home: const WordListScreen(),
    );
  }
}

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _wordController = TextEditingController();
  List<WordItem> _wordList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWordList(); // AC6: 앱 실행 시 저장된 데이터 로드
  }

  // shared_preferences 데이터 로드 (AC6)
  Future<void> _loadWordList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('word_list');
    if (savedData != null) {
      final List<dynamic> jsonList = jsonDecode(savedData);
      setState(() {
        _wordList = jsonList.map((e) => WordItem.fromJson(e)).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  // shared_preferences 데이터 저장 (AC6)
  Future<void> _saveWordList() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _wordList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('word_list', jsonString);
  }

  // 단어 추가 로직 (AC1, AC2, AC5 검증)
  void _addWord() {
    final rawText = _wordController.text;
    final trimmedText = rawText.trim();

    // AC2: 공백만 입력된 경우 차단
    if (trimmedText.isEmpty) {
      _showSnackBar('단어를 입력해 주세요.');
      return;
    }

    // AC5: 50자 초과 입력 시 차단
    if (trimmedText.length > 50) {
      _showSnackBar('단어는 50자 이내로 입력해 주세요.');
      return;
    }

    // AC1: 정상 추가
    final newWord = WordItem(
      id: DateTime.now().millisecondsSinceEpoch,
      word: trimmedText,
    );

    setState(() {
      _wordList.insert(0, newWord);
      _wordController.clear();
    });

    _saveWordList();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 상세 작성 화면 열기 (AC3 - 중간 크기 다이얼로그)
  void _openDetailDialog(WordItem item, int index) {
    final meaningController = TextEditingController(text: item.meaning);
    final usageController = TextEditingController(text: item.usage);
    final whyController = TextEditingController(text: item.whyNeeded);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
          ),
          title: Text(
            '🔥 ${item.word}',
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUniformTextField(
                    controller: meaningController,
                    label: '단어의 정의 / 뜻',
                    hint: '단어의 핵심 정의를 입력하세요',
                  ),
                  const SizedBox(height: 10),
                  _buildUniformTextField(
                    controller: usageController,
                    label: '강의 내 쓰임 및 예시',
                    hint: '강의 중 언급된 용례를 입력하세요',
                  ),
                  const SizedBox(height: 10),
                  _buildUniformTextField(
                    controller: whyController,
                    label: '이 단어가 필요한 이유',
                    hint: '학습에 이 개념이 필수적인 이유를 입력하세요',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  _wordList[index] = item.copyWith(
                    meaning: meaningController.text,
                    usage: usageController.text,
                    whyNeeded: whyController.text,
                  );
                });
                _saveWordList();
                Navigator.pop(context);
              },
              child: const Text(
                '저장',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // 규격화된 입력창 헬퍼 위젯 (2줄 고정 - 중간 크기)
  Widget _buildUniformTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 13,
        ),
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFF1E293B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '⚡ LECTURE WORD VAULT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // 딥 블루 & 오렌지 그라데이션 테마
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
              Color(0xFF431407),
              Color(0xFF7C2D12),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orangeAccent),
                )
              : Column(
                  children: [
                    // 단어 입력 영역 (AC1, AC2, AC5)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _wordController,
                              maxLength: 50,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '수업 중 모르는 단어 입력 (최대 50자)',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.4),
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _addWord(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.deepOrangeAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _addWord,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.white24,
                      indent: 16,
                      endIndent: 16,
                    ),
                    // 단어 목록 및 빈 상태 영역 (AC4)
                    Expanded(
                      child: _wordList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 64,
                                    color: Colors.orangeAccent.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '등록된 단어가 없습니다.\n강의 중 단어를 빠르게 캐치해보세요!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _wordList.length,
                              itemBuilder: (context, index) {
                                final item = _wordList[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: item.isDone
                                          ? Colors.blueAccent.withOpacity(0.4)
                                          : Colors.orangeAccent.withOpacity(
                                              0.6,
                                            ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      item.word,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: item.isDone
                                            ? Colors.white54
                                            : Colors.white,
                                        decoration: item.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.meaning.isNotEmpty
                                          ? '뜻: ${item.meaning}'
                                          : '📌 터치하여 상세 메모 추가',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: item.meaning.isNotEmpty
                                            ? Colors.orangeAccent
                                            : Colors.white38,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      value: item.isDone,
                                      activeColor: Colors.orangeAccent,
                                      checkColor: Colors.black,
                                      side: const BorderSide(
                                        color: Colors.orangeAccent,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _wordList[index] = item.copyWith(
                                            isDone: val,
                                          );
                                        });
                                        _saveWordList();
                                      },
                                    ),
                                    onTap: () => _openDetailDialog(item, index),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
