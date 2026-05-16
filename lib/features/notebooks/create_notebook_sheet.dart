import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'notebooks_provider.dart';

class CreateNotebookSheet extends ConsumerStatefulWidget {
  const CreateNotebookSheet({super.key});

  @override
  ConsumerState<CreateNotebookSheet> createState() => _CreateNotebookSheetState();
}

class _CreateNotebookSheetState extends ConsumerState<CreateNotebookSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCurrency = 'INR';
  int _selectedColor = 0xFF6C4FDB;
  bool _isSaving = false;

  final List<int> _colors = [
    0xFF6C4FDB, 0xFF2196F3, 0xFF4CAF50, 0xFFFF9800,
    0xFFE91E63, 0xFF009688, 0xFFFF5722, 0xFF607D8B,
  ];

  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AED', 'SGD'];

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await ref.read(notebooksProvider.notifier).addNotebook(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      currency: _selectedCurrency,
      color: _selectedColor,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('New Notebook',
              style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              )),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Notebook title',
                hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Currency
            Text('Currency',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              )),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _currencies.map((c) {
                  final isSelected = _selectedCurrency == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCurrency = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        ),
                      ),
                      child: Text(c,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                        )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Color
            Text('Color',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              )),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _colors.map((c) {
                  final isSelected = _selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 32, height: 32,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Notebook',
                        style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}