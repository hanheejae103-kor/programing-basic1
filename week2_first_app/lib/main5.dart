import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '스도쿠 Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SudokuGame(),
    );
  }
}

enum Difficulty { easy, medium, hard }

class SudokuGame extends StatefulWidget {
  const SudokuGame({super.key});

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame> {
  // 9x9 보드 데이터
  late List<List<int>> _solutionBoard;
  late List<List<int>> _currentBoard;
  late List<List<bool>> _isInitial; // 처음 주어진 고정 숫자인지 여부

  int? _selectedRow;
  int? _selectedCol;

  Difficulty _difficulty = Difficulty.easy;
  bool _isSolved = false;
  int _mistakes = 0;
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSolved) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _startNewGame() {
    _selectedRow = null;
    _selectedCol = null;
    _isSolved = false;
    _mistakes = 0;

    _generateSudoku();
    _startTimer();
    setState(() {});
  }

  // 스도쿠 보드 생성 알고리즘
  void _generateSudoku() {
    _solutionBoard = List.generate(9, (_) => List.filled(9, 0));
    _solveSudoku(_solutionBoard);

    // 복사본 생성
    _currentBoard = List.generate(
      9,
      (r) => List.generate(9, (c) => _solutionBoard[r][c]),
    );

    // 난이도별 제거할 칸 수 설정
    int removeCount;
    switch (_difficulty) {
      case Difficulty.easy:
        removeCount = 30;
        break;
      case Difficulty.medium:
        removeCount = 42;
        break;
      case Difficulty.hard:
        removeCount = 52;
        break;
    }

    final random = Random();
    int removed = 0;
    while (removed < removeCount) {
      int r = random.nextInt(9);
      int c = random.nextInt(9);
      if (_currentBoard[r][c] != 0) {
        _currentBoard[r][c] = 0;
        removed++;
      }
    }

    _isInitial = List.generate(
      9,
      (r) => List.generate(9, (c) => _currentBoard[r][c] != 0),
    );
  }

  // 백트래킹을 이용한 스도쿠 생성/해결기
  bool _solveSudoku(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle();
          for (int num in numbers) {
            if (_isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (_solveSudoku(board)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
      if (board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (board[startRow + r][startCol + c] == num) return false;
      }
    }
    return true;
  }

  void _inputNumber(int number) {
    if (_selectedRow == null || _selectedCol == null || _isSolved) return;

    int r = _selectedRow!;
    int c = _selectedCol!;

    // 초기 고정 칸은 수정 불가
    if (_isInitial[r][c]) return;

    setState(() {
      _currentBoard[r][c] = number;

      if (number != 0 && number != _solutionBoard[r][c]) {
        _mistakes++;
      }

      _checkWinCondition();
    });
  }

  void _checkWinCondition() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_currentBoard[r][c] != _solutionBoard[r][c]) {
          return;
        }
      }
    }
    _isSolved = true;
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스도쿠 (Sudoku)'),
        centerTitle: true,
        actions: [
          PopupMenuButton<Difficulty>(
            icon: const Icon(Icons.tune),
            tooltip: '난이도 설정',
            onSelected: (diff) {
              setState(() {
                _difficulty = diff;
                _startNewGame();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Difficulty.easy, child: Text('쉬움')),
              PopupMenuItem(value: Difficulty.medium, child: Text('보통')),
              PopupMenuItem(value: Difficulty.hard, child: Text('어려움')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
            tooltip: '새 게임',
          ),
        ],
      ),
      body: Column(
        children: [
          // 게임 정보 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '난이도: ${_difficulty == Difficulty.easy
                      ? "쉬움"
                      : _difficulty == Difficulty.medium
                      ? "보통"
                      : "어려움"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '실수: $_mistakes회',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _mistakes > 0 ? Colors.redAccent : Colors.white,
                  ),
                ),
                Text(
                  '시간: ${_secondsElapsed.toString().padLeft(3, '0')}초',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          if (_isSolved)
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text(
                '🎉 성공하셨습니다! 축하합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

          // 스도쿠 판
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                          ),
                      itemCount: 81,
                      itemBuilder: (context, index) {
                        int r = index ~/ 9;
                        int c = index % 9;
                        return _buildCell(r, c);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 숫자 입력패드
          _buildNumberPad(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCell(int r, int c) {
    bool isSelected = r == _selectedRow && c == _selectedCol;
    bool isInitial = _isInitial[r][c];
    int value = _currentBoard[r][c];
    bool isError = value != 0 && value != _solutionBoard[r][c];

    // 같은 숫자 강조
    int? selectedValue = (_selectedRow != null && _selectedCol != null)
        ? _currentBoard[_selectedRow!][_selectedCol!]
        : null;
    bool isSameValue =
        selectedValue != null && selectedValue != 0 && value == selectedValue;

    // 선택된 셀과 같은 행/열/3x3 영역 강조
    bool isInSameGroup =
        _selectedRow == r ||
        _selectedCol == c ||
        (_selectedRow != null &&
            _selectedCol != null &&
            (_selectedRow! ~/ 3 == r ~/ 3) &&
            (_selectedCol! ~/ 3 == c ~/ 3));

    Color cellColor = Colors.transparent;
    if (isSelected) {
      cellColor = Colors.indigo.shade700;
    } else if (isSameValue) {
      cellColor = Colors.blue.shade900.withOpacity(0.7);
    } else if (isInSameGroup) {
      cellColor = Colors.white10;
    }

    // 3x3 구분을 위한 굵은 테두리 설정
    BorderSide rightBorder = (c % 3 == 2 && c != 8)
        ? const BorderSide(color: Colors.white, width: 2)
        : const BorderSide(color: Colors.white24, width: 0.5);
    BorderSide bottomBorder = (r % 3 == 2 && r != 8)
        ? const BorderSide(color: Colors.white, width: 2)
        : const BorderSide(color: Colors.white24, width: 0.5);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRow = r;
          _selectedCol = c;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(right: rightBorder, bottom: bottomBorder),
        ),
        child: Center(
          child: Text(
            value == 0 ? '' : '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
              color: isError
                  ? Colors.redAccent
                  : (isInitial ? Colors.white : Colors.lightBlueAccent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...List.generate(9, (index) {
            int num = index + 1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blueGrey[800],
                  ),
                  onPressed: () => _inputNumber(num),
                  child: Text(
                    '$num',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                ),
                icon: const Icon(Icons.backspace_outlined, size: 20),
                onPressed: () => _inputNumber(0), // 지우기
                tooltip: '지우기',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
