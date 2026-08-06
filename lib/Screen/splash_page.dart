import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 2),
          () {
        if (!mounted) return;
        widget.onFinished();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6981FF),
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo2.png', // 두 번째 로고
          width: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}