import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';

import 'data/database/database_helper.dart';
import 'data/repositories/notebook_repository.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;

  runApp(
    const ProviderScope(
      child: LedgeBookApp(),
    ),
  );
}

class LedgeBookApp extends StatelessWidget {
  const LedgeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LedgeBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  Future<Widget> _resolveScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final onboardingComplete =
        prefs.getBool('onboarding_complete') ?? false;

    if (!onboardingComplete) {
      return const OnboardingScreen();
    }

    final lastNotebookId =
        prefs.getString('last_notebook_id');

    if (lastNotebookId != null) {
      final repo = NotebookRepository();

      final notebook =
          await repo.getById(lastNotebookId);

      if (notebook != null) {
        return MainShell(
          initialNotebook: notebook,
        );
      }
    }

    return const MainShell();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveScreen(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            ),
          );
        }

        return snapshot.data ??
            const MainShell();
      },
    );
  }
}