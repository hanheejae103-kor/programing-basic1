import 'package:flutter/material.dart';

void main() {
  runApp(const WindowsCalculatorApp());
}

class WindowsCalculatorApp extends StatelessWidget {
  const WindowsCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Windows 스타일 계산기',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[200], // 요청하셨던 연한 회색 배경
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
  String _display = '0'; // 메인 표시 화면
  String _expression = ''; // 상단 연산과정 표시
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  // 버튼 클릭 핸들러
  void _onButtonPressed(String label) {
    setState(() {
      if (['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(label)) {
        _handleNumber(label);
      } else if (label == '.') {
        _handleDot();
      } else if (['+', '-', '×', '÷'].contains(label)) {
        _handleOperator(label);
      } else if (label == '=') {
        _handleEquals();
      } else if (label == 'C') {
        _clearAll();
      } else if (label == 'CE') {
        _clearEntry();
      } else if (label == '⌫') {
        _handleBackspace();
      } else if (label == '±') {
        _toggleSign();
      }
    });
  }

  void _handleNumber(String number) {
    if (_display == '0' || _shouldResetDisplay) {
      _display = number;
      _shouldResetDisplay = false;
    } else {
      _display += number;
    }
  }

  void _handleDot() {
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
  }

  void _handleOperator(String op) {
    double currentNum = double.parse(_display);

    if (_firstOperand == null) {
      _firstOperand = currentNum;
    } else if (_operator != null && !_shouldResetDisplay) {
      _firstOperand = _calculate(_firstOperand!, currentNum, _operator!);
      _display = _formatResult(_firstOperand!);
    }

    _operator = op;
    _expression = '${_formatResult(_firstOperand!)} $op';
    _shouldResetDisplay = true;
  }

  void _handleEquals() {
    if (_firstOperand == null || _operator == null) return;

    double secondOperand = double.parse(_display);
    _expression =
        '${_formatResult(_firstOperand!)} $_operator ${_formatResult(secondOperand)} =';

    double result = _calculate(_firstOperand!, secondOperand, _operator!);
    _display = _formatResult(result);

    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = true;
  }

  double _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  void _clearAll() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = false;
  }

  void _clearEntry() {
    _display = '0';
  }

  void _handleBackspace() {
    if (_shouldResetDisplay) return;

    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
      if (_display == '-' || _display == '-0') _display = '0';
    } else {
      _display = '0';
    }
  }

  void _toggleSign() {
    if (_display == '0') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
  }

  String _formatResult(double val) {
    if (val.isNaN) return '0으로 나눌 수 없습니다';
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    return val.toString();
  }

  // 계산기 버튼 위젯 빌더
  Widget _buildButton(String label, {Color? bgColor, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.white,
            foregroundColor: textColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // 전체 배경색 연한 회색
      appBar: AppBar(
        title: const Text('계산기'),
        centerTitle: true,
        backgroundColor: Colors.orange, // 설정해 두셨던 오렌지색 타이틀 바
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 디스플레이 영역 (계산과정 및 결과)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 이전 연산 과정 표시
                    Text(
                      _expression,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    // 현재 입력 / 결과값 표시
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 키패드 버튼 영역 (윈도우 계산기 그리드 배치)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    // 1열: CE, C, ⌫, ÷
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildButton('CE', bgColor: Colors.grey[300]),
                          _buildButton('C', bgColor: Colors.grey[300]),
                          _buildButton('⌫', bgColor: Colors.grey[300]),
                          _buildButton(
                            '÷',
                            bgColor: Colors.orange[100],
                            textColor: Colors.orange[900],
                          ),
                        ],
                      ),
                    ),
                    // 2열: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton(
                            '×',
                            bgColor: Colors.orange[100],
                            textColor: Colors.orange[900],
                          ),
                        ],
                      ),
                    ),
                    // 3열: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton(
                            '-',
                            bgColor: Colors.orange[100],
                            textColor: Colors.orange[900],
                          ),
                        ],
                      ),
                    ),
                    // 4열: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton(
                            '+',
                            bgColor: Colors.orange[100],
                            textColor: Colors.orange[900],
                          ),
                        ],
                      ),
                    ),
                    // 5열: ±, 0, ., =
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildButton('±'),
                          _buildButton('0'),
                          _buildButton('.'),
                          _buildButton(
                            '=',
                            bgColor: Colors.orange,
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
