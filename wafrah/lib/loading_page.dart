import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'splash_screen.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentCoin = 0;

  // Target positions for each coin, shifted slightly to the left
  final List<Offset> _targetPositions = [
    const Offset(-0.1, -0.5), // Center top (shifted slightly left)
    const Offset(-0.6, 0.0), // Left center (shifted slightly left)
    const Offset(0.4, 0.5), // Right bottom (shifted slightly left)
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            _currentCoin < _targetPositions.length - 1) {
          // Move to next coin
          _currentCoin++;
          _controller.reset();
          _playCoinFlipSound();
          _controller.forward();
        }
      });

    _startAnimation();
  }

  void _startAnimation() {
    _playCoinFlipSound();
    _controller.forward().whenComplete(() async {
      await Future.delayed(
          const Duration(seconds: 1)); // Smooth transition delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    });
  }

  void _playCoinFlipSound() async {
    try {
      await _audioPlayer.play(AssetSource('coin-flip-88793.mp3'));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // Stop any ongoing playback
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/greenLogo.png',
              width: 150,
              height: 150,
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // Get the target position for the current coin
                final targetPosition = _targetPositions[_currentCoin];
                return Align(
                  alignment: Alignment(
                    targetPosition.dx, // Horizontal position (shifted left)
                    targetPosition.dy + _animation.value, // Vertical animation
                  ),
                  child: Visibility(
                    visible: _currentCoin < 3,
                    child: Image.asset(
                      'assets/images/coins.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
