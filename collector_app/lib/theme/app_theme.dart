import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primary = Color(0xFF75FF9E);
  static const Color _primaryContainer = Color(0xFF00E676);
  static const Color _onPrimary = Color(0xFF003918);
  static const Color _onPrimaryContainer = Color(0xFF00612E);
  
  static const Color _secondary = Color(0xFF88D899);
  
  static const Color _background = Color(0xFF071325);
  static const Color _surface = Color(0xFF071325);
  static const Color _surfaceContainerLowest = Color(0xFF030E20);
  static const Color _surfaceContainerLow = Color(0xFF101C2E);
  static const Color _surfaceContainer = Color(0xFF142032);
  static const Color _surfaceContainerHigh = Color(0xFF1F2A3D);
  static const Color _surfaceContainerHighest = Color(0xFF2A3548);
  
  static const Color _onSurface = Color(0xFFD7E3FC);
  static const Color _onSurfaceVariant = Color(0xFFBACBB9);
  
  static const Color _error = Color(0xFFFFB4AB);
  static const Color _errorContainer = Color(0xFF93000A);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primary,
      primaryContainer: _primaryContainer,
      onPrimary: _onPrimary,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _secondary,
      surfaceContainerLowest: _surfaceContainerLowest,
      surface: _surface,
      surfaceTint: _primary,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
      error: _error,
      errorContainer: _errorContainer,
    ),
    scaffoldBackgroundColor: _background,
    textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.w900, letterSpacing: -1.5),
      displayMedium: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.workSans(color: _onSurface),
      bodyMedium: GoogleFonts.workSans(color: _onSurfaceVariant),
      labelLarge: GoogleFonts.workSans(color: _onSurface, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    ),
    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        surfaceContainerLowest: _surfaceContainerLowest,
        surfaceContainerLow: _surfaceContainerLow,
        surfaceContainer: _surfaceContainer,
        surfaceContainerHigh: _surfaceContainerHigh,
        surfaceContainerHighest: _surfaceContainerHighest,
      ),
    ],
  );
}

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Color? surfaceContainerLowest;
  final Color? surfaceContainerLow;
  final Color? surfaceContainer;
  final Color? surfaceContainerHigh;
  final Color? surfaceContainerHighest;

  @override
  CustomColors copyWith({
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
  }) {
    return CustomColors(
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t),
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t),
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t),
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t),
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t),
    );
  }
}
