import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Ecomac',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppThemes.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppThemes.lightTheme.textTheme),
      ),
      darkTheme: AppThemes.darkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(AppThemes.darkTheme.textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}
