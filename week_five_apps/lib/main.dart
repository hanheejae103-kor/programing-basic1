import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '5주차 할 일 앱',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const TaskPage(),
    );
  }
}

// 1. TaskItem 데이터 클래스 (상태로 다룰 기본 단위)
class TaskItem {
  final String title;
  bool isDone;

  TaskItem({required this.title, this.isDone = false});
}

// 2. StatefulWidget: 화면은 가만히 있어도 내부 "상태"가 바뀔 수 있는 위젯의 틀
class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

// 3. State: 실제 변화하는 데이터(상태)를 보관하고 화면을 그리는 로직이 위치하는 곳
class _TaskPageState extends State<TaskPage> {
  // [원래 상태 (State Data)]
  // 슬라이드에 명시된 2개의 기본 할 일 목록을 원본 데이터 상태로 가집니다.
  final List<TaskItem> _tasks = [
    TaskItem(title: '5주차 강의 복습'),
    TaskItem(title: '상태 흐름도 작성'),
  ];

  // [계산된 상태 (Getter)]
  // 미완료된 항목만 필터링하여 '남은 할 일 수'를 동적으로 계산합니다.
  // 원본 데이터인 _tasks가 바뀌면 이 계산값도 자동으로 업데이트됩니다.
  int get _remainingCount => _tasks.where((task) => !task.isDone).length;

  // [이벤트 처리 메서드 (Event Handler)]
  // 사용자가 '완료' 또는 '취소' 버튼을 눌렀을 때 실행됩니다.
  void _toggleTask(int index) {
    // 핵심 동작 원리: setState()
    // 1) 상태값(_tasks[index].isDone)을 토글(true <-> false)시킵니다.
    // 2) setState()로 감싸서 Flutter 프레임워크에 "상태가 변했으니 화면(UI)을 다시 그려라(rebuild)!"라고 요청합니다.
    // 3) 이로 인해 build() 메서드가 다시 실행되어 카드 표시와 상단 숫자(남은 할 일 수)가 한 번에 바뀝니다.
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('나의 할 일 앱'),
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
              // -------------------------------------------------------------
              // 상단 제목 영역
              // -------------------------------------------------------------
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

              // -------------------------------------------------------------
              // 변화하는 부분 1: 남은 할 일 수 표시 영역
              // -------------------------------------------------------------
              // _remainingCount (계산된 상태)를 참조하므로 setState() 호출 시 숫자가 자동으로 달라집니다.
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

              // -------------------------------------------------------------
              // 변화하는 부분 2: 할 일 목록 카드 리스트
              // -------------------------------------------------------------
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = _tasks[index];

                  // 개별 카드 위젯 (상태에 따라 배경색, 아이콘, 버튼 텍스트 변경)
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? const Color(0xFFECFDF5) // 완료 시 연한 녹색 배경
                          : Colors.white, // 미완료 시 흰색 배경
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
                        // [상태 기반 아이콘] 완료 여부에 따라 체크/동그라미 표시
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

                        // [할 일 제목]
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                              decoration: task.isDone
                                  ? TextDecoration
                                        .none // 슬라이드 이미지 스타일에 맞춤
                                  : TextDecoration.none,
                            ),
                          ),
                        ),

                        // [이벤트 발생 버튼] 누르면 _toggleTask(index)를 호출
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
