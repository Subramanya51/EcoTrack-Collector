import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _authService.getToken();
    
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/greeting');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0D1F1A), Color(0xFF071325)],
            radius: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dot pattern overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: _DotPainter()),
              ),
            ),

            // Background image
            Positioned.fill(
              child: IgnorePointer(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuANcFH8mlroiOYOYg_Vym6m89c9sWyx4CMesnjsdnmmOVLVY9XBFCIwDFzXjXGeJT-fufK0SEZxmFlK6yrexoaXyym7IPxX1BM6id0lmIoHtbdjqfY-91zcq7KOfYH3KIvArBdVLRZLCZlURuGji9PbbZ6K3jUYPJhFhAV3marDDk7OaQADZ_3zMWHnx-byfCnE42R35B0OdAKRzfyJni8GxRT5cLFuL3jFo_4jEzkcP9AXGdu1WlNq-RJ7YxhxTj-GDZjiAxHzUS6b',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.12),
                  color: Colors.transparent,
                  colorBlendMode: BlendMode.overlay,
                ),
              ),
            ),

            // Branding cluster
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.3, end: 0.6).animate(_glowController),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x3375FF9E),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x8075FF9E),
                              blurRadius: 60,
                              spreadRadius: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: const Color(0x991F2A3D),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x0DFFFFFF)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.eco, color: Color(0xFF75FF9E), size: 72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                    children: [
                      TextSpan(text: 'ECO ', style: TextStyle(color: Color(0xFFD7E3FC))),
                      TextSpan(text: 'TRACK', style: TextStyle(color: Color(0xFF75FF9E))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'YOUR ROUTE. YOUR IMPACT.',
                  style: TextStyle(
                    color: Color(0xFFBACBB9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),

            // Footer section
            Positioned(
              bottom: 64,
              child: Column(
                children: [
                  Container(
                    width: 224,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 74,
                        decoration: BoxDecoration(
                          color: const Color(0xFF75FF9E),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x8075FF9E), blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'YOUR ROUTE. YOUR IMPACT.',
                    style: TextStyle(color: Color(0xFFD7E3FC), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(radius: 2, backgroundColor: Color(0x9975FF9E)),
                      SizedBox(width: 12),
                      CircleAvatar(radius: 2, backgroundColor: Color(0x4D75FF9E)),
                      SizedBox(width: 12),
                      CircleAvatar(radius: 2, backgroundColor: Color(0x1A75FF9E)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x8075FF9E)
      ..style = PaintingStyle.fill;
    for (double i = 0; i < size.width; i += 24) {
      for (double j = 0; j < size.height; j += 24) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
