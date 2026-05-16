import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/tag_model.dart';
import '../notebooks/notebooks_provider.dart';
import '../tags/tags_provider.dart';
import 'transactions_provider.dart';
import 'payment_methods_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final String? preselectedNotebookId;
  const AddTransactionSheet({super.key, this.preselectedNotebookId});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'cash_out';
  String? _selectedNotebookId;
  String? _selectedPaymentMethodId;
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedTagIds = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedNotebookId = widget.preselectedNotebookId;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_amountController.text.trim().isEmpty) return;
    if (_selectedNotebookId == null) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _isSaving = true);
    await ref.read(transactionsProvider.notifier).addTransaction(
      notebookId: _selectedNotebookId!,
      amount: amount,
      type: _type,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      paymentMethodId: _selectedPaymentMethodId,
      date: _selectedDate,
      tagIds: _selectedTagIds,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notebooksAsync = ref.watch(notebooksProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final methodsAsync = ref.watch(paymentMethodsProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('Add Transaction',
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    )),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        _typeButton('Out', 'cash_out', Colors.red.shade400),
                        _typeButton('In', 'cash_in', Colors.green.shade400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: GoogleFonts.inter(
                        fontSize: 32, fontWeight: FontWeight.w700,
                        color: _type == 'cash_out'
                            ? Colors.red.shade400
                            : Colors.green.shade500,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 32, fontWeight: FontWeight.w700,
                          color: AppTheme.borderColor,
                        ),
                        prefixText: '  ',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: 16),

                    // Notebook selector
                    _label('Notebook'),
                    const SizedBox(height: 8),
                    notebooksAsync.when(
                      loading: () => const SizedBox(),
                      error: (e, _) => const SizedBox(),
                      data: (notebooks) => notebooks.isEmpty
                          ? Text('Create a notebook first',
                              style: GoogleFonts.inter(color: Colors.red))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: notebooks.map((n) {
                                  final isSelected = _selectedNotebookId == n.id;
                                  final color = n.color != null
                                      ? Color(n.color!)
                                      : AppTheme.primaryColor;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedNotebookId = n.id),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? color.withOpacity(0.15)
                                            : AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? color
                                              : AppTheme.borderColor,
                                        ),
                                      ),
                                      child: Text(n.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? color
                                              : AppTheme.textSecondary,
                                        )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Note
                    _label('Note'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'What was this for?',
                        hintStyle:
                            GoogleFonts.inter(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tags
                    _label('Tags'),
                    const SizedBox(height: 8),
                    tagsAsync.when(
                      loading: () => const SizedBox(),
                      error: (e, _) => const SizedBox(),
                      data: (tags) => tags.isEmpty
                          ? Text('No tags yet — add some in Settings',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppTheme.textMuted))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tags.map((tag) {
                                final isSelected =
                                    _selectedTagIds.contains(tag.id);
                                final color = tag.color != null
                                    ? Color(tag.color!)
                                    : AppTheme.primaryColor;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (isSelected) {
                                      _selectedTagIds.remove(tag.id);
                                    } else {
                                      _selectedTagIds.add(tag.id);
                                    }
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withOpacity(0.15)
                                          : AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : AppTheme.borderColor,
                                      ),
                                    ),
                                    child: Text('# ${tag.name}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? color
                                            : AppTheme.textSecondary,
                                      )),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Payment method
                    _label('Payment Method'),
                    const SizedBox(height: 8),
                    methodsAsync.when(
                      loading: () => const SizedBox(),
                      error: (e, _) => const SizedBox(),
                      data: (methods) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: methods.map((m) {
                            final isSelected =
                                _selectedPaymentMethodId == m.id;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedPaymentMethodId = m.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.borderColor,
                                  ),
                                ),
                                child: Text(m.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondary,
                                  )),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date
                    _label('Date'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppTheme.textSecondary),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 14, color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _type == 'cash_out'
                              ? Colors.red.shade400
                              : Colors.green.shade500,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                _type == 'cash_out'
                                    ? 'Add Expense'
                                    : 'Add Income',
                                style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String label, String value, Color color) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
          style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          )),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ));
  }
}