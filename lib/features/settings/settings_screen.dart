import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/theme/app_theme.dart';
import '../tags/tags_screen.dart';
import 'payment_methods_screen.dart';
import '../../data/database/database_helper.dart';
import '../transactions/transactions_provider.dart';
import '../notebooks/notebooks_provider.dart';
import '../dashboard/dashboard_provider.dart';
import '../../main.dart';

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
            _divider(),
            _navTile(
              icon: Icons.backup_rounded,
              label: 'Backup & Restore',
              onTap: () => _showBackupRestoreDialog(),
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

  void _showBackupRestoreDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backup & Restore',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Back up your notebooks, transactions, and settings to Google Drive or restore from an existing backup.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _exportBackup();
                      },
                      icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                      label: const Text('Export Backup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _importBackup();
                      },
                      icon: const Icon(Icons.cloud_download_rounded, color: AppTheme.primaryColor),
                      label: const Text('Import Backup'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primaryColor),
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportBackup() async {
    try {
      await DatabaseHelper.instance.saveSharedPreferencesToDatabase();

      final dbPath = await getDatabasesPath();
      final localFile = File(p.join(dbPath, 'ledgebook.db'));

      if (!await localFile.exists()) {
        throw Exception('Database file not found!');
      }

      await DatabaseHelper.instance.closeDatabase();

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}';
      final backupFile = await localFile.copy(p.join(tempDir.path, 'ledgebook_backup_$dateStr.db'));

      await DatabaseHelper.instance.database;

      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'LedgeBook Backup $dateStr',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup file prepared successfully!',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup failed: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  Future<void> _importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final pickedPath = result.files.single.path!;
      final pickedFile = File(pickedPath);

      final bytes = await pickedFile.readAsBytes();
      if (bytes.length < 16) {
        throw Exception('Selected file is not a valid SQLite database.');
      }
      final header = String.fromCharCodes(bytes.take(15));
      if (header != 'SQLite format 3') {
        throw Exception('Selected file is not a valid LedgeBook backup.');
      }

      await DatabaseHelper.instance.closeDatabase();

      final dbPath = await getDatabasesPath();
      final localFile = File(p.join(dbPath, 'ledgebook.db'));
      await pickedFile.copy(localFile.path);

      await DatabaseHelper.instance.restoreSharedPreferencesFromDatabase();

      ref.invalidate(transactionsProvider);
      ref.invalidate(notebooksProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Restore Complete',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Your notebooks, transactions, and settings have been restored successfully! The app will now reload.',
                style: GoogleFonts.inter(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AppRouter()),
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Restore Failed',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),
              content: Text(
                'Could not restore database: $e',
                style: GoogleFonts.inter(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}