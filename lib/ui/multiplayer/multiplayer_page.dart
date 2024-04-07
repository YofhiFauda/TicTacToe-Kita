import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MultiplayerPage extends StatefulWidget {
  const MultiplayerPage({super.key});

  @override
  _MultiplayerPageState createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  final List<List<String>> _matrix = [
    ["", "", ""],
    ["", "", ""],
    ["", "", ""]
  ];

  String _currentPlayer = "X";
  int _scoreX = 0;
  int _scoreO = 0;

  Timer? _timer;
  int _currentDuration = 30;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
      value: 1, // Mulai dari 1 (100%)
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() async {
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
        title: Text(
          "Multiplayer",
          style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
        actions: [
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25.0, bottom: 10),
            child: Text(
              "Turn: $_currentPlayer",
              style: GoogleFonts.coiny(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 3,
              ),
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
                // padding: EdgeInsets.symmetric(horizontal: 50.0),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
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
    }
  }

  _resetScore() {
    setState(() {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          _matrix[i][j] = '';
        }
      }
      _currentPlayer = 'X';
      _scoreX = 0;
      _scoreO = 0;
    });
    _timer?.cancel();
    _startTimer();
  }

  _checkWinner() {
    for (int i = 0; i < 3; i++) {
      // Check baris
      if (_matrix[i][0] == _matrix[i][1] &&
          _matrix[i][1] == _matrix[i][2] &&
          _matrix[i][0] != '') {
        _declareWinner(_matrix[i][0]);
        return;
      }

      // Check kolom
      if (_matrix[0][i] == _matrix[1][i] &&
          _matrix[1][i] == _matrix[2][i] &&
          _matrix[0][i] != '') {
        _declareWinner(_matrix[0][i]);
        return;
      }
    }

    // Check diagonal
    if (_matrix[0][0] == _matrix[1][1] &&
        _matrix[1][1] == _matrix[2][2] &&
        _matrix[0][0] != '') {
      _declareWinner(_matrix[0][0]);
      return;
    }

    if (_matrix[0][2] == _matrix[1][1] &&
        _matrix[1][1] == _matrix[2][0] &&
        _matrix[0][2] != '') {
      _declareWinner(_matrix[0][2]);
      return;
    }

    // Cek apakah papan sudah penuh
    bool draw = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_matrix[i][j] == '') {
          draw = false;
          break;
        }
      }
    }

    if (draw) {
      _showDrawDialog();
    }
  }

  _resetGame() {
    setState(() {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          _matrix[i][j] = '';
        }
      }
    });
    _timer?.cancel();
    _startTimer();
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
          _handleTimeout(); // Tambahkan baris ini
        }
      });
    });
    _animationController!.reset();
    _animationController!.forward();
  }

  void _switchPlayer() {
    if (_currentPlayer != 'X') {
      _currentPlayer = 'O';
    } else {
      _currentPlayer = 'X';
    }
    _startTimer(); // Mulai timer untuk pemain selanjutnya
  }

  void _handleTimeout() {
    if (_currentPlayer == 'X') {
      _declareWinner('O');
    } else {
      _declareWinner('X');
    }
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
      // Jika hasilnya seri, Anda dapat menentukan giliran pemain dengan logika lain atau biarkan X memulai lagi.
      _currentPlayer = (Random().nextBool()) ? 'X' : 'O';
    }
  }

  _showWinnerDialog(String winner) {
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff4b4b),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Main Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        });
  }

  _showDrawDialog() {
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFff4b4b),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Main Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _resetGame();
                    Navigator.of(context).pop();
                  },
                ),
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
        _markBox(x, y);
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

  _markBox(int x, int y) {
    if (_matrix[x][y] == "") {
      setState(() {
        if (_currentPlayer == "X") {
          _matrix[x][y] = "X";
          _currentPlayer = "O";
        } else {
          _matrix[x][y] = "O";
          _currentPlayer = "X";
        }
      });
      _checkWinner();
      _switchPlayer();
    }
  }
}
