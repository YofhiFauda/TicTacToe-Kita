import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HardSinglePlayerPage extends StatefulWidget {
  @override
  _HardSinglePlayerPageState createState() => _HardSinglePlayerPageState();
}

class _HardSinglePlayerPageState extends State<HardSinglePlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  List<List<String>> _matrix = List.generate(3, (_) => List.filled(3, ''));
  String _currentPlayer = 'X';
  int _scoreX = 0;
  int _scoreO = 0;
  int _currentDuration = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
      value: 1, // Dimulai dari 100%
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8787),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Medium",
          style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: _resetScore,
              color: Colors.white,
              icon: const Icon(Icons.refresh),
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: _handleMenuClick,
            itemBuilder: (BuildContext context) {
              return {'Start as X', 'Start as O'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Peringatan !!'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFff4b4b),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Ya',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Ini menutup dialog
                          Navigator.pop(
                              context); // Ini kembali ke halaman sebelumnya
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Ini hanya menutup dialog
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25.0, bottom: 10),
            child: Text(
              "Turn: $_currentPlayer",
              style: GoogleFonts.coiny(
                  color: Colors.white, fontSize: 24, letterSpacing: 3),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _scoreX.toString(),
                  style: GoogleFonts.coiny(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    " : ",
                    style: GoogleFonts.coiny(
                        color: const Color(0xFFFFC93C),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3),
                  ),
                ),
                Text(
                  _scoreO.toString(),
                  style: GoogleFonts.coiny(
                    color: const Color(0xFF176B87),
                    fontSize: 40,
                    letterSpacing: 3,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.height / 2,
              margin: const EdgeInsets.all(8),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: _buildItem,
                itemCount: 9,
              ),
            ),
          ),
          LinearProgressIndicator(
            value: _currentDuration / 10,
            color: Colors.blue,
            backgroundColor: Colors.grey[200],
          ),
          Text(
            'Waktu tersisa: $_currentDuration detik',
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ],
      ),
    );
  }

// Handler untuk pemilihan menu
  void _handleMenuClick(String value) {
    if (value == 'Start as X') {
      _resetGame();
      setState(() {
        _currentPlayer = 'X';
      });
    } else {
      _resetGame();
      setState(() {
        _currentPlayer = 'O';
      });
      _computerMove();
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    int row = index ~/ 3;
    int col = index % 3;

    Color textColor;

    if (_matrix[row][col] == 'X') {
      textColor = Colors.white;
    } else if (_matrix[row][col] == 'O') {
      textColor = const Color(0xFF176B87);
    } else {
      textColor = Colors.transparent; //warna default
    }

    return GestureDetector(
      onTap: () => _onMarkBox(row, col),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFC93C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _matrix[row][col],
              style: GoogleFonts.coiny(
                color: textColor,
                fontSize: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMarkBox(int row, int col) {
    if (_matrix[row][col] == '') {
      setState(() {
        _matrix[row][col] = _currentPlayer;
      });

      if (!_checkWinner(row, col)) {
        _switchPlayer();
        _startTimer();
        if (_currentPlayer == 'O') {
          _computerMoveAfterDelay();
        }
      }
    }
  }

  void _computerMoveAfterDelay() async {
    // Menunggu 2 detik sebelum komputer bergerak (ubah sesuai kebutuhan)
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      // Cek apakah state masih terpasang
      if (_currentPlayer == 'O') {
        _computerMove();
      }
    }
  }

  bool _checkWinner(int x, int y) {
    var col = 0, row = 0, diag = 0, rdiag = 0;
    var n = _matrix.length;
    var playerResult = _currentPlayer;

    for (int i = 0; i < n; i++) {
      if (_matrix[x][i] == playerResult) col++;
      if (_matrix[i][y] == playerResult) row++;
      if (_matrix[i][i] == playerResult) diag++;
      if (_matrix[i][n - i - 1] == playerResult) rdiag++;
    }

    if (row == n || col == n || diag == n || rdiag == n) {
      _declareWinner(_currentPlayer);
      return true;
    }

    bool isFull = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_matrix[i][j] == "") {
          isFull = false;
          break;
        }
      }
    }
    if (isFull) {
      _showDrawDialog();
      return true;
    }
    return false;
  }

  void _declareWinner(String winner) {
    _timer?.cancel();
    _showWinnerDialog(winner);
    if (winner == "X") {
      _scoreX += 1;
      _currentPlayer = 'X';
    } else if (winner == "O") {
      _scoreO += 1;
      _currentPlayer = 'O';
    } else {
      // Jika hasilnya seri, tentukan giliran pemain secara acak
      _currentPlayer = (Random().nextBool()) ? 'X' : 'O';
    }
  }

  void _handleTimeout() {
    if (_currentPlayer == 'X') {
      _declareWinner('O');
    } else {
      _declareWinner('X');
    }
  }

  void _startTimer() {
    _currentDuration = 10;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentDuration > 0) {
          _currentDuration--;
        } else {
          _timer!.cancel();
          _handleTimeout();
        }
      });
    });
    _animationController!.reset();
    _animationController!.forward();
  }

  void _computerMove() {
    Future.delayed(const Duration(milliseconds: 200), () {
      int bestValue = -1000;
      Point bestMove = const Point(-1, -1);

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (_matrix[i][j] == '') {
            _matrix[i][j] = 'O';
            int moveVal = _minimax(0, false, -1000, 1000);
            _matrix[i][j] = '';

            if (moveVal > bestValue) {
              bestMove = Point(i, j);
              bestValue = moveVal;
            }
          }
        }
      }

      setState(() {
        _matrix[bestMove.x.toInt()][bestMove.y.toInt()] = 'O';
      });

      _checkWinner(bestMove.x.toInt(), bestMove.y.toInt());
      _startTimer();
      _switchPlayer();
    });
  }

  int _minimax(int depth, bool isMax, int alpha, int beta) {
    int score = _evaluate();

    if (score == 10) return score;
    if (score == -10) return score;
    if (_isMovesLeft() == false) return 0;

    if (isMax) {
      int best = -1000;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (_matrix[i][j] == '') {
            _matrix[i][j] = 'O';
            best = max(
              best,
              _minimax(depth + 1, !isMax, alpha, beta) - depth,
            );
            _matrix[i][j] = '';
            alpha = max(alpha, best);

            if (beta <= alpha) break;
          }
        }
      }
      return best;
    } else {
      int best = 1000;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (_matrix[i][j] == '') {
            _matrix[i][j] = 'X';
            best = min(
              best,
              _minimax(depth + 1, !isMax, alpha, beta) + depth,
            );
            _matrix[i][j] = '';
            beta = min(beta, best);

            if (beta <= alpha) break;
          }
        }
      }
      return best;
    }
  }

  int _evaluate() {
    // Cek baris untuk kemenangan 'O' atau 'X'
    for (int row = 0; row < 3; row++) {
      if (_matrix[row][0] == _matrix[row][1] &&
          _matrix[row][1] == _matrix[row][2]) {
        if (_matrix[row][0] == 'O') {
          return 10;
        } else if (_matrix[row][0] == 'X') return -10;
      }
    }

    // Cek kolom untuk kemenangan 'O' atau 'X'
    for (int col = 0; col < 3; col++) {
      if (_matrix[0][col] == _matrix[1][col] &&
          _matrix[1][col] == _matrix[2][col]) {
        if (_matrix[0][col] == 'O') {
          return 10;
        } else if (_matrix[0][col] == 'X') return -10;
      }
    }

    // Cek diagonal untuk kemenangan 'O' atau 'X'
    if (_matrix[0][0] == _matrix[1][1] && _matrix[1][1] == _matrix[2][2]) {
      if (_matrix[0][0] == 'O') {
        return 10;
      } else if (_matrix[0][0] == 'X') return -10;
    }

    if (_matrix[0][2] == _matrix[1][1] && _matrix[1][1] == _matrix[2][0]) {
      if (_matrix[0][2] == 'O') {
        return 10;
      } else if (_matrix[0][2] == 'X') return -10;
    }

    // Jika tidak ada yang menang, kembalikan 0
    return 0;
  }

  bool _isMovesLeft() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_matrix[i][j] == '') return true;
      }
    }
    return false;
  }

  void _switchPlayer() {
    setState(() {
      if (_currentPlayer == 'X') {
        _currentPlayer = 'O';
      } else {
        _currentPlayer = 'X';
      }
    });
  }

  void _showWinnerDialog(String winner) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Pemenangnya : Player $winner",
              style: GoogleFonts.coiny(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff4b4b),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Main Lagi',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _resetGame();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _showDrawDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Hasilnya Seri!",
              style: GoogleFonts.coiny(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff4b4b),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Main Lagi',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _resetGame();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _resetScore() {
    setState(() {
      _matrix = List.generate(3, (_) => List.filled(3, ''));
      _currentPlayer = 'X';
      _scoreX = 0;
      _scoreO = 0;
    });
    _timer?.cancel();
    _startTimer();
  }

  void _resetGame() {
    setState(() {
      _matrix = List.generate(3, (_) => List.filled(3, ''));
      _currentPlayer = 'X';
    });
    _timer?.cancel();
    _startTimer();
  }
}
