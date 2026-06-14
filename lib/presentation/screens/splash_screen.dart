import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 6.28).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A1428), const Color(0xFF1A3A52)]
                : [Colors.blue.shade50, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0288D1).withAlpha(150),
                            blurRadius: 32,
                            spreadRadius: 16,
                          ),
                        ],
                        border: Border.all(color: const Color(0xFF0288D1), width: 3),
                      ),
                      child: const Icon(
                        Icons.navigation,
                        size: 60,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'COMPASS GO',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0288D1),
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Precision in Motion',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF0288D1).withAlpha(180),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: const Color(0xFF0288D1).withAlpha(50),
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0288D1).withAlpha(200)),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
