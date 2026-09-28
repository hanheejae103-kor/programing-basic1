import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '지뢰찾기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const MinesweeperGame(),
    );
  }
}

enum Difficulty { easy, medium, hard }

class BoardConfig {
  final int rows;
  final int cols;
  final int mines;

  const BoardConfig({
    required this.rows,
    required this.cols,
    required this.mines,
  });
}

class Tile {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int neighborMines;

  Tile({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighborMines = 0,
  });
}

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key});

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> {
  static const Map<Difficulty, BoardConfig> configs = {
    Difficulty.easy: BoardConfig(rows: 8, cols: 8, mines: 10),
    Difficulty.medium: BoardConfig(rows: 10, cols: 10, mines: 15),
    Difficulty.hard: BoardConfig(rows: 12, cols: 12, mines: 25),
  };

  Difficulty _currentDifficulty = Difficulty.easy;
  late List<List<Tile>> _board;
  bool _isGameOver = false;
  bool _isGameWon = false;
  bool _flagMode = false;
  bool _firstClick = true;

  int _flagCount = 0;
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
      if (!_isGameOver && !_isGameWon) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _startNewGame() {
    _stopTimer();
    final config = configs[_currentDifficulty]!;
    _isGameOver = false;
    _isGameWon = false;
    _firstClick = true;
    _flagCount = 0;
    _secondsElapsed = 0;

    _board = List.generate(
      config.rows,
      (_) => List.generate(config.cols, (_) => Tile()),
    );

    setState(() {});
  }

  void _initMines(int startRow, int startCol) {
    final config = configs[_currentDifficulty]!;
    int placedMines = 0;
    final random = Random();

    while (placedMines < config.mines) {
      int r = random.nextInt(config.rows);
      int c = random.nextInt(config.cols);

      if ((r - startRow).abs() <= 1 && (c - startCol).abs() <= 1) continue;

      if (!_board[r][c].isMine) {
        _board[r][c].isMine = true;
        placedMines++;
      }
    }

    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        if (_board[r][c].isMine) continue;
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = r + dr;
            int nc = c + dc;
            if (nr >= 0 && nr < config.rows && nc >= 0 && nc < config.cols) {
              if (_board[nr][nc].isMine) count++;
            }
          }
        }
        _board[r][c].neighborMines = count;
      }
    }
  }

  void _onTileTap(int r, int c) {
    if (_isGameOver || _isGameWon) return;

    if (_flagMode) {
      _toggleFlag(r, c);
      return;
    }

    final tile = _board[r][c];
    if (tile.isFlagged || tile.isRevealed) return;

    if (_firstClick) {
      _firstClick = false;
      _initMines(r, c);
      _startTimer();
    }

    if (tile.isMine) {
      _triggerGameOver();
      return;
    }

    _revealTile(r, c);
    _checkWinCondition();
  }

  void _toggleFlag(int r, int c) {
    final tile = _board[r][c];
    if (tile.isRevealed) return;

    setState(() {
      tile.isFlagged = !tile.isFlagged;
      _flagCount += tile.isFlagged ? 1 : -1;
    });
  }

  void _revealTile(int r, int c) {
    final config = configs[_currentDifficulty]!;
    if (r < 0 || r >= config.rows || c < 0 || c >= config.cols) return;

    final tile = _board[r][c];
    if (tile.isRevealed || tile.isFlagged) return;

    setState(() {
      tile.isRevealed = true;
    });

    if (tile.neighborMines == 0 && !tile.isMine) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr != 0 || dc != 0) {
            _revealTile(r + dr, c + dc);
          }
        }
      }
    }
  }

  void _triggerGameOver() {
    _stopTimer();
    setState(() {
      _isGameOver = true;
      final config = configs[_currentDifficulty]!;
      for (int r = 0; r < config.rows; r++) {
        for (int c = 0; c < config.cols; c++) {
          if (_board[r][c].isMine) {
            _board[r][c].isRevealed = true;
          }
        }
      }
    });
  }

  void _checkWinCondition() {
    final config = configs[_currentDifficulty]!;
    bool won = true;

    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        final tile = _board[r][c];
        if (!tile.isMine && !tile.isRevealed) {
          won = false;
          break;
        }
      }
    }

    if (won) {
      _stopTimer();
      setState(() {
        _isGameWon = true;
      });
    }
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.amber;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = configs[_currentDifficulty]!;
    final remainingMines = config.mines - _flagCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('지뢰찾기'),
        centerTitle: true,
        actions: [
          PopupMenuButton<Difficulty>(
            icon: const Icon(Icons.bar_chart),
            tooltip: '난이도 설정',
            onSelected: (diff) {
              setState(() {
                _currentDifficulty = diff;
                _startNewGame();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Difficulty.easy, child: Text('쉬움 (8x8)')),
              PopupMenuItem(
                value: Difficulty.medium,
                child: Text('보통 (10x10)'),
              ),
              PopupMenuItem(value: Difficulty.hard, child: Text('어려움 (12x12)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard(Icons.brightness_5, '$remainingMines', '남은 지뢰'),
                IconButton(
                  iconSize: 40,
                  icon: Icon(
                    _isGameOver
                        ? Icons.sentiment_very_dissatisfied
                        : (_isGameWon
                              ? Icons.sentiment_very_satisfied
                              : Icons.sentiment_satisfied),
                    color: Colors.amber,
                  ),
                  onPressed: _startNewGame,
                  tooltip: '새 게임',
                ),
                _infoCard(
                  Icons.timer,
                  '${_secondsElapsed.toString().padLeft(3, '0')}s',
                  '시간',
                ),
              ],
            ),
          ),
          if (_isGameWon)
            Container(
              color: Colors.green,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text(
                '🎉 승리했습니다! 축하합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          if (_isGameOver)
            Container(
              color: Colors.redAccent,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: const Text(
                '💥 지뢰가 터졌습니다! 다시 시도해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: config.cols / config.rows,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: config.cols,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: config.rows * config.cols,
                    itemBuilder: (context, index) {
                      int r = index ~/ config.cols;
                      int c = index % config.cols;
                      final tile = _board[r][c];

                      return GestureDetector(
                        onTap: () => _onTileTap(r, c),
                        onSecondaryTap: () => _toggleFlag(r, c),
                        child: Container(
                          decoration: BoxDecoration(
                            color: tile.isRevealed
                                ? (tile.isMine ? Colors.red : Colors.grey[800])
                                : Colors.blueGrey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(child: _buildTileContent(tile)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _flagMode = !_flagMode;
          });
        },
        backgroundColor: _flagMode ? Colors.redAccent : Colors.indigo,
        icon: Icon(_flagMode ? Icons.flag : Icons.touch_app),
        label: Text(_flagMode ? '깃발 모드 ON' : '열기 모드 ON'),
      ),
    );
  }

  Widget _buildTileContent(Tile tile) {
    if (tile.isRevealed) {
      if (tile.isMine) {
        return const Text('💣', style: TextStyle(fontSize: 18));
      } else if (tile.neighborMines > 0) {
        return Text(
          '${tile.neighborMines}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getNumberColor(tile.neighborMines),
          ),
        );
      }
      return const SizedBox.shrink();
    } else if (tile.isFlagged) {
      return const Text('🚩', style: TextStyle(fontSize: 18));
    }
    return const SizedBox.shrink();
  }

  Widget _infoCard(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
