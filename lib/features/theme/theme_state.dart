part of 'theme_bloc.dart';

@immutable
class ThemeState extends Equatable {
  const ThemeState({
    required this.themeData,
    required this.themeMode,
    required this.themeEventType,
  });

  final ThemeData themeData;
  final ThemeMode themeMode;
  final ThemeType themeEventType;

  static const Color creamPrimary = Color(0xFFF5E6D3);
  static const Color creamPrimaryDark = Color(0xFFD4C4B0);
  static const Color creamPrimaryLight = Color(0xFFB89A7A);
  static const Color creamDark = Color(0xFFE8DCC6);

  @override
  List<Object?> get props => [themeData, themeMode, themeEventType];
}

class DarkThemeState extends ThemeState {
  const DarkThemeState({
    required super.themeData,
    required super.themeMode,
    required super.themeEventType,
  });

  static ThemeState get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return ThemeState(
      themeData: baseTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
        colorScheme: ColorScheme.dark(
          primary: ThemeState.creamPrimaryDark,
          onPrimary: const Color(0xFF1A1A1A),
          secondary: ThemeState.creamDark,
          onSecondary: const Color(0xFF1A1A1A),
          surface: const Color(0xFF0C0C0C),
          onSurface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0C0C0C),
      ),
      themeMode: ThemeMode.dark,
      themeEventType: ThemeType.darkMode,
    );
  }
}

class LightThemeState extends ThemeState {
  const LightThemeState({
    required super.themeData,
    required super.themeMode,
    required super.themeEventType,
  });

  static ThemeState get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return ThemeState(
      themeData: baseTheme.copyWith(
        textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
        colorScheme: ColorScheme.light(
          primary: ThemeState.creamPrimaryLight,
          onPrimary: const Color(0xFFFFFFFF),
          secondary: ThemeState.creamPrimaryDark,
          onSecondary: const Color(0xFF1A1A1A),
          surface: const Color(0xFFF4F5F6),
          onSurface: const Color(0xFF0E121D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F6),
      ),
      themeMode: ThemeMode.light,
      themeEventType: ThemeType.lightMode,
    );
  }
}

class SystemThemeState extends ThemeState {
  const SystemThemeState({
    required super.themeData,
    required super.themeMode,
    required super.themeEventType,
  });

  static ThemeState get systemTheme {
    return ThemeState(
      themeData: LightThemeState.lightTheme.themeData,
      themeMode: ThemeMode.system,
      themeEventType: ThemeType.system,
    );
  }
}
