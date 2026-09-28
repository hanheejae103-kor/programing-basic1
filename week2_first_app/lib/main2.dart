import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '더하기 계산기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // 입력 필드 조작을 위한 컨트롤러
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();

  // 계산 결과를 저장할 변수
  String _result = '결과가 여기에 표시됩니다';

  // 더하기 계산 함수
  void _calculateSum() {
    final String text1 = _num1Controller.text;
    final String text2 = _num2Controller.text;

    // 입력값이 비어있는지 확인
    if (text1.isEmpty || text2.isEmpty) {
      setState(() {
        _result = '두 숫자를 모두 입력해 주세요.';
      });
      return;
    }

    // 문자열을 숫자로 변환 후 합산
    final double? num1 = double.tryParse(text1);
    final double? num2 = double.tryParse(text2);

    if (num1 != null && num2 != null) {
      final double sum = num1 + num2;
      setState(() {
        // 소수점이 없으면 정수로, 있으면 소수점 그대로 표시
        _result = '결과: ${sum % 1 == 0 ? sum.toInt() : sum}';
      });
    } else {
      setState(() {
        _result = '올바른 숫자를 입력해 주세요.';
      });
    }
  }

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(137, 170, 159, 159),
      appBar: AppBar(
        title: const Text(
          '한희재의 간단한 더하기 계산기',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 첫 번째 입력창
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '첫 번째 숫자',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 두 번째 입력창
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '두 번째 숫자',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 더하기 버튼
            ElevatedButton(
              onPressed: _calculateSum,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // 버튼 너비를 가득 채움
              ),
              child: const Text('더하기', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),

            // 결과 출력 텍스트
            Text(
              _result,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
