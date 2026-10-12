import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '5주차 과제 - 상태 기능과 작업 컨텍스트',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const TaskPage(),
    );
  }
}

/// [도메인 모델]
class TaskItem {
  final String title;
  bool isDone;

  TaskItem({required this.title, this.isDone = false});
}

/// [가변 위젯 인터페이스]
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

/// [상태 관리 및 UI 렌더링 클래스]
/// - 상태 소유자: _TaskPageState
class _TaskPageState extends State<TaskPage> {
  // [AC1] 원본 상태: 초기값 정의 ([false, false])
  final List<TaskItem> _tasks = [
    TaskItem(title: '5주차 강의 복습'),
    TaskItem(title: '상태 흐름도 작성'),
  ];

  // [AC4] 계산된 상태: 원본 상태(_tasks)에서 상태를 직접 계산 (중복 저장 X)
  int get _remainingCount => _tasks.where((task) => !task.isDone).length;

  // [AC2, AC3] 이벤트 처리 함수: 입력에 응답하여 상태와 UI 동시 변경 및 원복
  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('5주차 과제 - 할 일 앱'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E293B), width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '나의 할 일',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // [AC1, AC2, AC3] 남은 할 일 수 표시
              Row(
                children: [
                  const Text(
                    '남은 할 일 ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Text(
                    '$_remainingCount',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // [AC2, AC3] 할 일 목록 및 토글 버튼
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? const Color(0xFFECFDF5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: task.isDone
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isDone
                              ? Icons.check_rounded
                              : Icons.radio_button_unchecked,
                          color: task.isDone
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _toggleTask(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: task.isDone
                                  ? const Color(0xFFCCFBF1)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.isDone ? '취소' : '완료',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: task.isDone
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
