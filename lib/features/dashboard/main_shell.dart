import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/notebook_model.dart';

import 'home_screen.dart';

import '../notebooks/notebooks_screen.dart';
import '../notebooks/notebook_detail_screen.dart';

import '../transactions/add_transaction_screen.dart';
import '../analytics/analytics_screen.dart';
import '../calendar/calendar_screen.dart';

class MainShell extends StatefulWidget {
  final NotebookModel? initialNotebook;

  const MainShell({
    super.key,
    this.initialNotebook,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    NotebooksScreen(),
    AnalyticsScreen(),
    CalendarScreen(),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialNotebook != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotebookDetailScreen(
              notebook: widget.initialNotebook!,
            ),
          ),
        );
      });
    }
  }

  int _tabToScreenIndex(int tabIndex) {
    if (tabIndex <= 1) return tabIndex;
    return tabIndex - 1;
  }

  int _screenToTabIndex(int screenIndex) {
    if (screenIndex <= 1) return screenIndex;
    return screenIndex + 1;
  }

  void _onTabTapped(int tabIndex) {
    if (tabIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddTransactionSheet(),
      );
      return;
    }

    setState(() {
      _currentIndex = _tabToScreenIndex(tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          border: Border(
            top: BorderSide(
              color: Color(0xFFF3F4F6),
            ),
          ),
        ),

        child: BottomNavigationBar(
          currentIndex: _screenToTabIndex(_currentIndex),

          onTap: _onTabTapped,

          type: BottomNavigationBarType.fixed,

          backgroundColor: AppTheme.surfaceColor,

          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textMuted,

          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),

          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
          ),

          elevation: 0,

          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Notebooks',
            ),

            BottomNavigationBarItem(
              icon: Container(
                width: 46,
                height: 46,

                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              label: '',
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}