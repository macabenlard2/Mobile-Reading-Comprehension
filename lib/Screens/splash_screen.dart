import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reading_comprehension/authentication_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textScale;
  late Animation<double> _textFade;
  late Animation<double> _progressValue;
  late Animation<Color?> _backgroundColor;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Define animations
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _backgroundColor = ColorTween(
      begin: const Color(0xFF2E7D32), // Darker green
      end: const Color(0xFF4CAF50), // Original green
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation sequence
    _controller.forward();

    // Navigate to the main page after animations complete
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isNavigating) {
        _isNavigating = true;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Container(
                color: const Color(0xFF4CAF50),
                child: const AuthenticationWrapper(),
              );
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              const curve = Curves.easeInOut;
              
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var opacityAnimation = animation.drive(tween);
              
              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColor.value ?? const Color(0xFF4CAF50),
                  const Color(0xFFFFEB3B), // Yellow
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background elements
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GameStyleBackgroundPainter(
                      animationValue: _controller.value,
                    ),
                  ),
                ),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with scale and fade animation
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _logoFade,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/appbar.png',
                              height: 130,
                              width: 130,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // App name with scale and fade animation
                      ScaleTransition(
                        scale: _textScale,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: const Text(
                            "CISC KIDS",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 6.0,
                                  color: Colors.black38,
                                  offset: Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      FadeTransition(
                        opacity: _textFade,
                        child: const Text(
                          "READING COMPREHENSION",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Game-style progress indicator
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      children: [
                        // Animated progress bar container
                        Container(
                          height: 20,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Progress bar background
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              
                              // Animated progress fill
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final progressWidth = constraints.maxWidth * _progressValue.value;
                                  return Stack(
                                    children: [
                                      // Yellow progress fill
                                      Container(
                                        width: progressWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFD600),
                                              Color(0xFFFFEB3B),
                                            ],
                                            stops: [0.3, 1.0],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.yellow.withOpacity(0.6),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // White dot at the end of the progress
                                      if (progressWidth > 0)
                                        Positioned(
                                          left: progressWidth - 10, // Position at the end of the progress
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 20,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Loading text with pulsing animation
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.5 + 0.5 * sin(_controller.value * 10),
                              child: Text(
                                "Loading adventure...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for game-style background with animated elements
class _GameStyleBackgroundPainter extends CustomPainter {
  final double animationValue;
  
  _GameStyleBackgroundPainter({required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw animated stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.7);
    final bigStarPaint = Paint()..color = Colors.yellow.withOpacity(0.8);
    
    // Draw multiple stars with varying positions and sizes
    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      final radius = 1.0 + (i % 3).toDouble();
      
      // Make some stars twinkle
      final opacity = 0.3 + 0.7 * ((sin(animationValue * 10 + i) + 1) / 2);
      
      if (i % 5 == 0) {
        // Bigger yellow stars
        canvas.drawCircle(
          Offset(x, y), 
          radius * 1.5, 
          bigStarPaint..color = Colors.yellow.withOpacity(opacity)
        );
      } else {
        // Regular white stars
        canvas.drawCircle(
          Offset(x, y), 
          radius, 
          starPaint..color = Colors.white.withOpacity(opacity * 0.7)
        );
      }
    }
    
    // Draw some simple landscape elements (hills)
    final hillPaint = Paint()
      ..color = const Color(0xFF388E3C).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    // First hill
    final hillPath1 = Path();
    hillPath1.moveTo(0, size.height);
    hillPath1.quadraticBezierTo(
      size.width * 0.25, 
      size.height - 100 - 20 * sin(animationValue * 5), 
      size.width, 
      size.height
    );
    canvas.drawPath(hillPath1, hillPaint);
    
    // Second hill
    final hillPath2 = Path();
    hillPath2.moveTo(0, size.height);
    hillPath2.quadraticBezierTo(
      size.width * 0.75, 
      size.height - 150 - 30 * cos(animationValue * 5), 
      size.width, 
      size.height
    );
    canvas.drawPath(hillPath2, hillPaint..color = const Color(0xFF1B5E20).withOpacity(0.3));
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}