import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/main_shell.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedCurrency = 'INR';
  String _selectedTheme = 'system';
  bool _isSaving = false;

  final List<Map<String, String>> _currencies = [
    {'code': 'INR', 'label': '₹  Indian Rupee'},
    {'code': 'USD', 'label': '\$  US Dollar'},
    {'code': 'EUR', 'label': '€  Euro'},
    {'code': 'GBP', 'label': '£  British Pound'},
    {'code': 'JPY', 'label': '¥  Japanese Yen'},
    {'code': 'AED', 'label': 'AED  UAE Dirham'},
    {'code': 'SGD', 'label': 'S\$  Singapore Dollar'},
  ];

  final List<Map<String, dynamic>> _themes = [
    {'value': 'system', 'label': 'System', 'icon': Icons.brightness_auto_rounded},
    {'value': 'light', 'label': 'Light', 'icon': Icons.light_mode_rounded},
    {'value': 'dark', 'label': 'Dark', 'icon': Icons.dark_mode_rounded},
  ];

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_currency', _selectedCurrency);
    await prefs.setString('theme', _selectedTheme);
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.book_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),

              Text(
                'Welcome to\nLedgeBook',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick setup before you start.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Currency
              Text(
                'Default Currency',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(14),
                    items: _currencies.map((c) => DropdownMenuItem(
                      value: c['code'],
                      child: Text(c['label']!, style: GoogleFonts.inter(fontSize: 15)),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Theme
              Text(
                'App Theme',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: _themes.map((t) {
                  final isSelected = _selectedTheme == t['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTheme = t['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              t['icon'] as IconData,
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t['label'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Get Started',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}