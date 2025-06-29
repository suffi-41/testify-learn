import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _logoOpacity = 0.0;
  double _textOffset = 40.0;
  Timer? _timer;
  late AnimationController _bgAnimationController;

  // ✅ Image logic for web and app
  ImageProvider getLogoImage() {
    if (kIsWeb) {
      return const AssetImage("assets/images/testify_learn.gif");
    } else {
      return const AssetImage("assets/images/testify_learn.webp");
    }
  }

  @override
  void initState() {
    super.initState();

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _logoOpacity = 1.0;
          _textOffset = 0.0;
        });
      }
    });

    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final colorAnimation1 = ColorTween(
      begin: scheme.primary.withOpacity(0.6),
      end: scheme.secondary.withOpacity(0.6),
    ).animate(_bgAnimationController);

    final colorAnimation2 = ColorTween(
      begin: scheme.surface.withOpacity(0.6),
      end: scheme.background.withOpacity(0.6),
    ).animate(_bgAnimationController);

    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorAnimation1.value ?? scheme.primary,
                  colorAnimation2.value ?? scheme.background,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: _logoOpacity,
                    duration: const Duration(seconds: 2),
                    child: Hero(
                      tag: 'app-logo',
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image(
                            image: getLogoImage(),
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    transform: Matrix4.translationValues(0, _textOffset, 0),
                    curve: Curves.easeOut,
                    child: Text(
                      "Testify Learn",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
