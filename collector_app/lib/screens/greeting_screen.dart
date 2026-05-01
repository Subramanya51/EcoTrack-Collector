import 'package:flutter/material.dart';

class GreetingScreen extends StatelessWidget {
  const GreetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F1A),
      body: Stack(
        children: [
          // Ambient gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x000D1F1A), Color(0xCC071325)],
                  center: Alignment.center,
                  radius: 1.0,
                ),
              ),
            ),
          ),

          // Center content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Opacity(
                    opacity: 0.4,
                    child: Icon(Icons.recycling, color: Color(0xFF00E676), size: 64),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'GOOD MORNING, COLLECTOR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD7E3FC),
                      letterSpacing: -2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ready for today's route?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xCCBACBB9),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0, left: 0, right: 0, height: 256,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF0D1F1A), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // LIVE MAP FAB
          Positioned(
            bottom: 48, right: 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LIVE MAP',
                  style: TextStyle(color: Color(0xE6D7E3FC), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3),
                ),
                const SizedBox(width: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => Navigator.pushNamed(context, '/map'),
                    child: Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00E676),
                        boxShadow: [BoxShadow(color: Color(0x3300E676), blurRadius: 40)],
                      ),
                      child: const Icon(Icons.map, color: Color(0xFF003918), size: 36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
