import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_router.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'secure-base',
      theme: ThemeData(
        textTheme: GoogleFonts.mPlusRounded1cTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.text,
          error: Colors.red,
          onError: Colors.white,
          surface: AppColors.background,
          onSurface: AppColors.text,
        ),
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.w500),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.w500),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: GoogleFonts.mPlusRounded1c(fontWeight: FontWeight.w500),
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.mPlusRounded1c(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.mPlusRounded1c(color: AppColors.textLight),
          hintStyle: GoogleFonts.mPlusRounded1c(color: AppColors.textLight),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
