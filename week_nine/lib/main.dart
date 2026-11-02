import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const AutoGuardApp());
}

class AutoGuardApp extends StatelessWidget {
  const AutoGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auto Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEF4444),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const WarningLightHomeScreen(),
    );
  }
}

// 1. 데이터 모델
class WarningLightItem {
  final String id;
  final String name;
  final String engName;
  final String category; // 'red', 'amber', 'green'
  final String symbolType; // 실제 심볼 그리기 타입
  final String urgency;
  final String verdict;
  final List<String> actions;
  final List<String> causes;

  WarningLightItem({
    required this.id,
    required this.name,
    required this.engName,
    required this.category,
    required this.symbolType,
    required this.urgency,
    required this.verdict,
    required this.actions,
    required this.causes,
  });
}

// 2. 경고등 데이터셋
final List<WarningLightItem> warningLightsData = [
  WarningLightItem(
    id: 'steering',
    name: '파워 스티어링 (EPS)',
    engName: 'Power Steering',
    category: 'red',
    symbolType: 'steering',
    urgency: '위험 (조향 불능)',
    verdict: '핸들이 묵직해짐 (안전지대 정차)',
    actions: ['핸들 조작이 매우 무거워지므로 두 손으로 단단히 잡으세요.', '안전지대에 정차 후 시동을 껐다 다시 켜보세요.'],
    causes: ['EPS 모터 과열/고장', '스티어링 퓨즈 단선'],
  ),
  WarningLightItem(
    id: 'oil',
    name: '엔진오일 압력',
    engName: 'Oil Pressure',
    category: 'red',
    symbolType: 'oil',
    urgency: '치명적 (엔진 손상)',
    verdict: '즉시 시동 오프 (견인 필요)',
    actions: ['시동을 즉시 끄고 유량 딥스틱을 확인하세요.', '오일량이 부족해도 주행하지 마세요.'],
    causes: ['엔진오일 유출/부족', '오일 펌프 이상'],
  ),
  WarningLightItem(
    id: 'battery',
    name: '배터리/충전 경고',
    engName: 'Battery Charge',
    category: 'red',
    symbolType: 'battery',
    urgency: '위험 (전통 마비)',
    verdict: '가까운 정비소로 즉시 이동',
    actions: ['에어컨, 라이트 등 전기장치를 끄세요.', '시동이 꺼지면 재시동이 안됩니다.'],
    causes: ['알터네이터(발전기) 고장', '팬벨트 끊어짐'],
  ),
  WarningLightItem(
    id: 'engine',
    name: '엔진 체크등',
    engName: 'Check Engine',
    category: 'amber',
    symbolType: 'engine',
    urgency: '주의 (점검 요망)',
    verdict: '서행 주행 가능 (급가속 금지)',
    actions: ['주유 직후라면 주유 캡을 꽉 닫으세요.', '출력 이상 확인 후 정비소로 가세요.'],
    causes: ['산소 센서 고장', '주유 캡 열림', '점화 플러그 노후'],
  ),
  WarningLightItem(
    id: 'brake',
    name: '브레이크 경고등',
    engName: 'Brake Warning',
    category: 'red',
    symbolType: 'brake',
    urgency: '위험 (제동 불능)',
    verdict: '주행 절대 금지',
    actions: ['갓길 정차 후 주차 브레이크 해제 여부를 확인하세요.', '브레이크 액을 점검하세요.'],
    causes: ['브레이크 오일 부족', '주차 브레이크 작동 중'],
  ),
  WarningLightItem(
    id: 'tpms',
    name: 'TPMS 공기압',
    engName: 'Tire Pressure',
    category: 'amber',
    symbolType: 'tpms',
    urgency: '주의 (공기압 부족)',
    verdict: '서행 주행 가능 (펑크 확인)',
    actions: ['타이어 외관 펑크 여부를 점검하세요.', '공기압을 보충하세요.'],
    causes: ['타이어 못 박힘', '기온 저하로 인한 공기 수축'],
  ),
];

// 3. 실제 자동차 계기판 심볼을 직접 그리는 CustomPainter
class WarningSymbolPainter extends CustomPainter {
  final String symbolType;
  final Color color;

  WarningSymbolPainter({required this.symbolType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    switch (symbolType) {
      case 'steering': // EPS 스티어링 휠 + 느낌표
        canvas.drawCircle(center, size.width * 0.35, paint);
        canvas.drawCircle(center, size.width * 0.1, fillPaint);
        canvas.drawLine(
          Offset(center.dx - size.width * 0.35, center.dy),
          Offset(center.dx - size.width * 0.1, center.dy),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + size.width * 0.1, center.dy),
          Offset(center.dx + size.width * 0.35, center.dy),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy + size.width * 0.1),
          Offset(center.dx, center.dy + size.width * 0.35),
          paint,
        );
        // 느낌표 (!)
        final exPaint = Paint()
          ..color = color
          ..strokeWidth = 2.5;
        canvas.drawLine(
          Offset(center.dx + size.width * 0.28, center.dy - size.width * 0.35),
          Offset(center.dx + size.width * 0.28, center.dy - size.width * 0.15),
          exPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + size.width * 0.28, center.dy - size.width * 0.05),
          1.5,
          fillPaint,
        );
        break;

      case 'oil': // 오일 주전자
        final path = Path();
        path.moveTo(size.width * 0.2, size.height * 0.65);
        path.lineTo(size.width * 0.7, size.height * 0.65);
        path.lineTo(size.width * 0.8, size.height * 0.45);
        path.lineTo(size.width * 0.3, size.height * 0.45);
        path.close();
        canvas.drawPath(path, paint);
        // 주둥이 및 물방울
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.55),
          Offset(size.width * 0.9, size.height * 0.4),
          paint,
        );
        canvas.drawCircle(
          Offset(size.width * 0.92, size.height * 0.48),
          2.5,
          fillPaint,
        );
        break;

      case 'battery': // 배터리 (+/-)
        final rect = Rect.fromLTWH(
          size.width * 0.15,
          size.height * 0.35,
          size.width * 0.7,
          size.height * 0.4,
        );
        canvas.drawRect(rect, paint);
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * 0.28,
            size.height * 0.27,
            size.width * 0.12,
            size.height * 0.08,
          ),
          fillPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * 0.6,
            size.height * 0.27,
            size.width * 0.12,
            size.height * 0.08,
          ),
          fillPaint,
        );
        // + 와 - 표시
        canvas.drawLine(
          Offset(size.width * 0.25, size.height * 0.55),
          Offset(size.width * 0.35, size.height * 0.55),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.65, size.height * 0.55),
          Offset(size.width * 0.75, size.height * 0.55),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.5),
          Offset(size.width * 0.7, size.height * 0.6),
          paint,
        );
        break;

      case 'engine': // 엔진 모양
        final path = Path();
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * 0.25,
              size.height * 0.35,
              size.width * 0.5,
              size.height * 0.35,
            ),
            const Radius.circular(4),
          ),
        );
        canvas.drawPath(path, paint);
        canvas.drawLine(
          Offset(size.width * 0.15, size.height * 0.45),
          Offset(size.width * 0.25, size.height * 0.45),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.75, size.height * 0.4),
          Offset(size.width * 0.85, size.height * 0.4),
          paint,
        );
        break;

      case 'brake': // 브레이크 ( ( ! ) )
        canvas.drawCircle(center, size.width * 0.25, paint);
        // 느낌표
        canvas.drawLine(
          Offset(center.dx, center.dy - 6),
          Offset(center.dx, center.dy + 1),
          paint,
        );
        canvas.drawCircle(Offset(center.dx, center.dy + 6), 1.5, fillPaint);
        // 양옆 괄호
        final leftPath = Path()
          ..addArc(
            Rect.fromCircle(center: center, radius: size.width * 0.35),
            2.4,
            1.5,
          );
        final rightPath = Path()
          ..addArc(
            Rect.fromCircle(center: center, radius: size.width * 0.35),
            -0.8,
            1.5,
          );
        canvas.drawPath(leftPath, paint);
        canvas.drawPath(rightPath, paint);
        break;

      default: // TPMS 등 기본 항아리 모양
        final rect = Rect.fromLTWH(
          size.width * 0.25,
          size.height * 0.25,
          size.width * 0.5,
          size.height * 0.5,
        );
        canvas.drawRect(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. 메인 화면 UI
class WarningLightHomeScreen extends StatefulWidget {
  const WarningLightHomeScreen({Key? key}) : super(key: key);

  @override
  State<WarningLightHomeScreen> createState() => _WarningLightHomeScreenState();
}

class _WarningLightHomeScreenState extends State<WarningLightHomeScreen> {
  String _selectedCategory = 'all';
  final Set<String> _selectedIds = {};

  List<WarningLightItem> get _filteredList {
    if (_selectedCategory == 'red') {
      return warningLightsData.where((item) => item.category == 'red').toList();
    } else if (_selectedCategory == 'amber') {
      return warningLightsData
          .where((item) => item.category == 'amber')
          .toList();
    }
    return warningLightsData;
  }

  Color _getCategoryColor(String category) {
    return category == 'red'
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
  }

  void _openSingleDiagnostic(WarningLightItem item) {
    final itemColor = _getCategoryColor(item.category);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CustomPaint(
                      painter: WarningSymbolPainter(
                        symbolType: item.symbolType,
                        color: itemColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.urgency,
                        style: TextStyle(
                          color: itemColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '운행 제언: ${item.verdict}',
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '즉시 조치 단계',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...item.actions.map(
                (act) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '• $act',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        title: const Text(
          '차량 계기판 경고등 진단',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 카테고리 탭
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildCatTab('all', '전체 (${warningLightsData.length})'),
                _buildCatTab('red', '🔴 위험'),
                _buildCatTab('amber', '🟡 경고'),
              ],
            ),
          ),

          // 경고등 그리드 목록 (일정한 크기 유지)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 화면 너비에 따라 카드를 일정한 비율로 유지
                int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9, // 카드가 거대해지지 않도록 비율 고정
                  ),
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    final item = _filteredList[index];
                    final isSelected = _selectedIds.contains(item.id);
                    final itemColor = _getCategoryColor(item.category);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(item.id);
                          } else {
                            _selectedIds.add(item.id);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEF4444).withOpacity(0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF334155),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 실제 경고등 커스텀 심볼
                            Container(
                              width: 52,
                              height: 52,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF1E293B),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: itemColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: WarningSymbolPainter(
                                  symbolType: item.symbolType,
                                  color: itemColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.engName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white38,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 28,
                              child: TextButton.icon(
                                onPressed: () => _openSingleDiagnostic(item),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF334155),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                                label: const Text(
                                  '상세 진단',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatTab(String catKey, String label) {
    final isSelected = _selectedCategory == catKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedCategory = catKey);
          }
        },
      ),
    );
  }
}
