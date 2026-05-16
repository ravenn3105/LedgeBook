import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../tags/tags_screen.dart';
import 'payment_methods_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currency = 'INR';
  String _theme = 'system';

  final List<Map<String, String>> _currencies = [
    {'code': 'INR', 'label': '₹  Indian Rupee'},
    {'code': 'USD', 'label': '\$  US Dollar'},
    {'code': 'EUR', 'label': '€  Euro'},
    {'code': 'GBP', 'label': '£  British Pound'},
    {'code': 'JPY', 'label': '¥  Japanese Yen'},
    {'code': 'AED', 'label': 'AED  UAE Dirham'},
    {'code': 'SGD', 'label': 'S\$  Singapore Dollar'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currency = prefs.getString('default_currency') ?? 'INR';
      _theme = prefs.getString('theme') ?? 'system';
    });
  }

  Future<void> _saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_currency', currency);
    setState(() => _currency = currency);
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    setState(() => _theme = theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Preferences'),
          const SizedBox(height: 8),

          // Currency
          _card(children: [
            _tile(
              icon: Icons.currency_rupee_rounded,
              label: 'Default Currency',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currency,
                  alignment: Alignment.centerRight,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                  items: _currencies.map((c) => DropdownMenuItem(
                    value: c['code'],
                    child: Text(c['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textPrimary,
                      )),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) _saveCurrency(val);
                  },
                ),
              ),
            ),
          ]),

          const SizedBox(height: 12),

          // Theme
          _card(children: [
            _tile(
              icon: Icons.palette_rounded,
              label: 'App Theme',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _theme,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                  items: [
                    DropdownMenuItem(value: 'system',
                      child: Text('System', style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textPrimary))),
                    DropdownMenuItem(value: 'light',
                      child: Text('Light', style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textPrimary))),
                    DropdownMenuItem(value: 'dark',
                      child: Text('Dark', style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textPrimary))),
                  ],
                  onChanged: (val) {
                    if (val != null) _saveTheme(val);
                  },
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('Manage'),
          const SizedBox(height: 8),

          _card(children: [
            _navTile(
              icon: Icons.label_rounded,
              label: 'Tags',
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TagsScreen())),
            ),
            _divider(),
            _navTile(
              icon: Icons.payment_rounded,
              label: 'Payment Methods',
              onTap: () => Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => const PaymentMethodsScreen())),
            ),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('About'),
          const SizedBox(height: 8),

          _card(children: [
            _tile(
              icon: Icons.info_rounded,
              label: 'Version',
              trailing: Text('1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textMuted,
                )),
            ),
            _divider(),
            _tile(
              icon: Icons.storage_rounded,
              label: 'Storage',
              trailing: Text('Local only',
                style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textMuted,
                )),
            ),
            _divider(),
            _tile(
              icon: Icons.lock_rounded,
              label: 'Privacy',
              trailing: Text('No data leaves device',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.textMuted,
                )),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 0.8,
      ));
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
  required IconData icon,
  required String label,
  required Widget trailing,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            )),
        ),
        trailing,
      ],
    ),
  );
}

  Widget _navTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 14),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              )),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 50, color: AppTheme.borderColor);
  }
}