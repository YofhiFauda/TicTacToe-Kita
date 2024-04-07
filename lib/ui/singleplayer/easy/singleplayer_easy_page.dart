import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EasySinglePlayerPage extends StatefulWidget {
  const EasySinglePlayerPage({Key? key}) : super(key: key);

  @override
  _EasySinglePlayerPageState createState() => _EasySinglePlayerPageState();
}

class _EasySinglePlayerPageState extends State<EasySinglePlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  List<List<String>> _matrix =
      List.generate(3, (_) => List.filled(3, '')); // Papan permainan 3x3
  String _currentPlayer = 'X';
  int _scoreX = 0;
  int _scoreO = 0;
  int _currentDuration = 30;
  Timer? _timer;
  final String _gameMode = "SinglePlayer";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
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
                          Navigator.of(context).pop(); // Menutup dialog
                          Navigator.pop(
                              context); // Kembali ke halaman sebelumnya
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
                          Navigator.of(context).pop(); // Hanya menutup dialog
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
        title: Text(
          "Easy",
          style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
        actions: [
          IconButton(
            onPressed: _resetScore,
            color: Colors.white,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
            value: _currentDuration / 30,
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

  void _resetScore() {
    setState(() {
      // Reset papan dan variabel skor
      _matrix = List.generate(3, (_) => List.filled(3, ''));
      // Reset skor
      _scoreX = 0;
      _scoreO = 0;
    });
    _timer?.cancel();
    _startTimer();
  }

  void _computerMoveAfterDelay() async {
    // Menunggu 2 detik sebelum komputer bergerak
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Cek apakah state masih terpasang
      if (_currentPlayer == 'O') {
        _moveRandomly();
      }
    }
  }

  void _moveRandomly() {
    Future.delayed(Duration(seconds: 3), () {
      List<Point> availableMoves = [];

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (_matrix[i][j] == '') {
            availableMoves.add(Point(i, j));
          }
        }
      }

      if (availableMoves.isNotEmpty) {
        int randomIndex = Random().nextInt(availableMoves.length);
        Point move = availableMoves[randomIndex];
        setState(() {
          _matrix[move.x.toInt()][move.y.toInt()] = 'O';
        });
        _checkWinner();
        _startTimer();
        _switchPlayer();
      }
    });
  }

  void _resetGame(String startingPlayer) {
    setState(() {
      _matrix = List.generate(3, (_) => List.filled(3, ''));
      _currentPlayer =
          startingPlayer; // Mengatur _currentPlayer ke pemain yang harus mulai
    });
    _timer?.cancel();
    _startTimer();

    if (_currentPlayer == 'O') {
      _moveRandomly();
    }
  }

  void _switchPlayer() {
    setState(() {
      if (_currentPlayer == 'X') {
        _currentPlayer = 'O';
        if (_gameMode == "SinglePlayer") {
          _moveRandomly();
        }
      } else {
        _currentPlayer = 'X';
      }
    });
  }

  bool _checkWinner() {
    // Logika yang sama untuk memeriksa pemenang seperti yang ada pada kode sebelumnya
    for (int i = 0; i < 3; i++) {
      // Cek baris
      if (_matrix[i][0] == _matrix[i][1] &&
          _matrix[i][1] == _matrix[i][2] &&
          _matrix[i][0] != "") {
        _declareWinner(_matrix[i][0]);
        return true;
      }

      // Cek kolom
      if (_matrix[0][i] == _matrix[1][i] &&
          _matrix[1][i] == _matrix[2][i] &&
          _matrix[0][i] != "") {
        _declareWinner(_matrix[0][i]);
        return true;
      }
    }

    // Cek diagonal
    if (_matrix[0][0] == _matrix[1][1] &&
        _matrix[1][1] == _matrix[2][2] &&
        _matrix[0][0] != "") {
      _declareWinner(_matrix[0][0]);
      return true;
    }

    // Cek diagonal lain
    if (_matrix[0][2] == _matrix[1][1] &&
        _matrix[1][1] == _matrix[2][0] &&
        _matrix[0][2] != "") {
      _declareWinner(_matrix[0][2]);
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

  void _markBox(int x, int y) {
    if (_matrix[x][y] == "" && _currentPlayer == 'X') {
      setState(() {
        _matrix[x][y] = _currentPlayer;
      });
      bool isGameEnded = _checkWinner(); // Periksa pemenang atau hasil seri
      if (!isGameEnded) {
        _switchPlayer(); // Hanya beralih pemain jika permainan belum berakhir
        _startTimer();

        if (_currentPlayer == 'X') {
          // Cek apakah pemain 'X' sudah menang segera setelah langkahnya
          _computerMoveAfterDelay();
        }
      }
    }
  }

  void _startTimer() {
    _currentDuration = 30;
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

  void _handleTimeout() {
    if (_currentPlayer == 'X') {
      _declareWinner('O');
    } else {
      _declareWinner('X');
    }
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
                  _resetGame(_currentPlayer);
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
                  _resetGame(_currentPlayer);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _buildItem(BuildContext context, int index) {
    int x, y = 0;
    x = (index / 3).floor();
    y = (index % 3);

    Color textColor;

    if (_matrix[x][y] == 'X') {
      textColor = Colors.white;
    } else if (_matrix[x][y] == 'O') {
      textColor = const Color(0xFF176B87);
    } else {
      textColor = Colors.transparent; //warna default
    }

    return GestureDetector(
      onTap: () {
        if (_currentPlayer == 'X') {
          _markBox(x, y);
        } // Jika O (komputer), pemain tidak dapat menandai kotak
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFC93C),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _matrix[x][y],
            style: GoogleFonts.coiny(
              color: textColor,
              fontSize: 40,
            ),
          ),
        ),
      ),
    );
  }
}
