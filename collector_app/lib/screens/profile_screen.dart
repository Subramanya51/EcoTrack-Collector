import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return Scaffold(
      backgroundColor: const Color(0xFF071325),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071325),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E676)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Collector Profile',
          style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Avatar ring
            Container(
              width: 128, height: 128,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x3300E676), width: 2),
                boxShadow: const [BoxShadow(color: Color(0x1A00E676), blurRadius: 50)],
              ),
              child: const Icon(Icons.account_circle, color: Color(0xFF00E676), size: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'Active Collector',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFD7E3FC)),
            ),
            const SizedBox(height: 8),
            const Text(
              'AUTHORIZED PERSONNEL ONLY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFFBACBB9)),
            ),
            const SizedBox(height: 48),

            // Credentials card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(32)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xCC142032), Color(0xE6101C2E)],
                ),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 30, offset: Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // Collector ID
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fingerprint, color: Color(0xFF00E676)),
                          SizedBox(width: 16),
                          Text(
                            'COLLECTOR ID',
                            style: TextStyle(color: Color(0xFFBACBB9), fontWeight: FontWeight.w600, letterSpacing: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0x80101C2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'ET-4829-9910',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD7E3FC), letterSpacing: 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock, color: Color(0xFF00E676)),
                          SizedBox(width: 16),
                          Text(
                            'PASSWORD',
                            style: TextStyle(color: Color(0xFFBACBB9), fontWeight: FontWeight.w600, letterSpacing: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0x80101C2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _obscurePassword ? '••••••••' : 'EC0-SECURE-88',
                              style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD7E3FC), letterSpacing: 3),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF00E676),
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Logout button
            Material(
              color: const Color(0x3393000A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0x4DFFB4AB), width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                child: const SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Color(0xFFFFB4AB), size: 32),
                      SizedBox(width: 16),
                      Text(
                        'LOGOUT',
                        style: TextStyle(color: Color(0xFFFFB4AB), fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'SESSION ID: 4829-9910-AA21',
              style: TextStyle(color: Color(0x66BACBB9), fontSize: 10, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
