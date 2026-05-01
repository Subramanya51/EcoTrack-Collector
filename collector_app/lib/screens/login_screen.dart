import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _collectorIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final collectorId = _collectorIdController.text.trim();
    final password = _passwordController.text.trim();

    if (collectorId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Collector ID and Password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.login(collectorId, password);
      
      if (!mounted) return;

      if (token != null) {
        Navigator.pushReplacementNamed(context, '/greeting');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _collectorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      body: Stack(
        children: [
          // BG glow blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x0D75FF9E),
                boxShadow: [BoxShadow(color: Color(0x0D75FF9E), blurRadius: 120, spreadRadius: 50)],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x0D75FF9E),
                boxShadow: [BoxShadow(color: Color(0x0D75FF9E), blurRadius: 120, spreadRadius: 50)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                          ),
                          child: const Icon(Icons.eco, color: Color(0xFF75FF9E), size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ECO TRACK',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF75FF9E), letterSpacing: 3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your route. Your impact.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFBACBB9), letterSpacing: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Collector ID field
                    _CustomTextField(
                      label: 'Collector ID',
                      icon: Icons.badge,
                      hint: 'ID-000-000',
                      colors: colors,
                      controller: _collectorIdController,
                    ),
                    const SizedBox(height: 32),
                    _CustomTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      hint: '••••••••',
                      obscureText: true,
                      colors: colors,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 40),

                    // Login button
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF75FF9E), Color(0xFF00E676)],
                        ),
                        boxShadow: const [BoxShadow(color: Color(0x3300E676), blurRadius: 30, offset: Offset(0, 10))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isLoading ? null : _handleLogin,
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Color(0xFF003918))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'LOGIN',
                                        style: TextStyle(color: Color(0xFF003918), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(Icons.arrow_forward, color: Color(0xFF003918)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Footer note
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0x80101C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x1A3B4A3D)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: Color(0xFFBACBB9), fontSize: 12, height: 1.5, letterSpacing: 1),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "CONTACT YOUR SUPERVISOR.",
                            style: TextStyle(color: Color(0xFFD7E3FC), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Decor image
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 200,
            child: IgnorePointer(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCQabzu4RtDv28XaHciH83jBoGfGHgaRX1008u3nHpnhYYUhJsSV_ynY97C5AvBxf6WlIDW6J1oRCGA3I2py-odaREtCn8dBkC9i03HqPkSqNkl_I-TF3R5QN4o62s1UVsjvuNIpJ7KH4SJ-bFaNVda2pt8Ugz5r5CEOILqJ9JnuGqZh_lMBxOq1WT_Z8yXqg0lxnmY3-hWX-E6-FECKpLzXKndhIx64pjtDxpy7YG3l_CEmt-WE2P0cvWzM2-IsExAyAZAl1AUkDsz',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final CustomColors colors;
  final TextEditingController controller;

  const _CustomTextField({
    required this.label,
    required this.icon,
    required this.hint,
    required this.colors,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF75FF9E), size: 24),
            const SizedBox(width: 16),
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFFBACBB9)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFD7E3FC)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DBACBB9)),
            filled: true,
            fillColor: colors.surfaceContainerLow,
            border: const UnderlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF75FF9E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),
        ),
      ],
    );
  }
}
