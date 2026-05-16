import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/notebook_model.dart';
import '../../data/models/payment_method_model.dart';
import '../notebooks/notebooks_provider.dart';
import '../transactions/payment_methods_provider.dart';
import 'search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final notebooksAsync = ref.watch(notebooksProvider);
    final methodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (filters.hasActiveFilters)
            TextButton(
              onPressed: () {
                ref.read(searchFiltersProvider.notifier).state =
                    const SearchFilters();
                _searchController.clear();
              },
              child: Text('Clear all',
                style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.red,
                  fontWeight: FontWeight.w600,
                )),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(searchFiltersProvider.notifier).state =
                    filters.copyWith(query: val);
              },
              style: GoogleFonts.inter(
                fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search notes, tags, notebooks...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                          color: AppTheme.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchFiltersProvider.notifier).state =
                              filters.copyWith(query: '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Type filter
                _filterChip(
                  label: filters.type == null
                      ? 'All Types'
                      : filters.type == 'cash_in'
                          ? 'Income'
                          : 'Expenses',
                  isActive: filters.type != null,
                  onTap: () => _showTypeFilter(context, ref, filters),
                ),
                const SizedBox(width: 8),

                // Notebook filter
                notebooksAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (notebooks) => _filterChip(
                    label: filters.notebookId == null
                        ? 'All Notebooks'
                        : notebooks
                              .firstWhere(
                                (n) => n.id == filters.notebookId,
                                orElse: () => notebooks.first,
                              )
                              .title,
                    isActive: filters.notebookId != null,
                    onTap: () => _showNotebookFilter(
                        context, ref, filters, notebooks),
                  ),
                ),
                const SizedBox(width: 8),

                // Payment method filter
                methodsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, _) => const SizedBox(),
                  data: (methods) => _filterChip(
                    label: filters.paymentMethodId == null
                        ? 'All Methods'
                        : methods
                              .firstWhere(
                                (m) => m.id == filters.paymentMethodId,
                                orElse: () => methods.first,
                              )
                              .name,
                    isActive: filters.paymentMethodId != null,
                    onTap: () => _showMethodFilter(
                        context, ref, filters, methods),
                  ),
                ),
                const SizedBox(width: 8),

                // Date filter
                _filterChip(
                  label: filters.fromDate == null
                      ? 'Any Date'
                      : '${DateFormat('dd MMM').format(filters.fromDate!)} → ${filters.toDate != null ? DateFormat('dd MMM').format(filters.toDate!) : 'now'}',
                  isActive: filters.fromDate != null,
                  onTap: () => _showDateFilter(context, ref, filters),
                ),
                const SizedBox(width: 8),

                // Amount filter
                _filterChip(
                  label: filters.minAmount == null && filters.maxAmount == null
                      ? 'Any Amount'
                      : '${filters.minAmount?.toStringAsFixed(0) ?? '0'} - ${filters.maxAmount?.toStringAsFixed(0) ?? '∞'}',
                  isActive: filters.minAmount != null || filters.maxAmount != null,
                  onTap: () => _showAmountFilter(context, ref, filters),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.borderColor),

          // Results
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (results) {
                if (filters.query.isEmpty && !filters.hasActiveFilters) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded,
                          size: 48,
                          color: AppTheme.primaryColor.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('Search your transactions',
                          style: GoogleFonts.inter(
                            fontSize: 15, color: AppTheme.textSecondary,
                          )),
                      ],
                    ),
                  );
                }
                if (results.isEmpty) {
                  return Center(
                    child: Text('No results found',
                      style: GoogleFonts.inter(
                        fontSize: 15, color: AppTheme.textSecondary,
                      )),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text('${results.length} results',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        )),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        itemCount: results.length,
                        itemBuilder: (_, i) => _transactionTile(results[i]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              )),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final isIn = tx.type == 'cash_in';
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isIn ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isIn ? Colors.green.shade500 : Colors.red.shade400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.note ?? (isIn ? 'Income' : 'Expense'),
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  )),
                Text(DateFormat('dd MMM yyyy').format(date),
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textMuted,
                  )),
              ],
            ),
          ),
          Text(
            '${isIn ? '+' : '-'}INR ${tx.amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: isIn ? Colors.green.shade500 : Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeFilter(
      BuildContext context, WidgetRef ref, SearchFilters filters) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _filterSheet(
        title: 'Filter by Type',
        children: [
          _sheetOption('All Types', filters.type == null, () {
            ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(type: null);
            Navigator.pop(context);
          }),
          _sheetOption('Income only', filters.type == 'cash_in', () {
            ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(type: 'cash_in');
            Navigator.pop(context);
          }),
          _sheetOption('Expenses only', filters.type == 'cash_out', () {
            ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(type: 'cash_out');
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  void _showNotebookFilter(BuildContext context, WidgetRef ref,
      SearchFilters filters, List<NotebookModel> notebooks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _filterSheet(
        title: 'Filter by Notebook',
        children: [
          _sheetOption('All Notebooks', filters.notebookId == null, () {
            ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(notebookId: null);
            Navigator.pop(context);
          }),
          ...notebooks.map((n) => _sheetOption(
            n.title,
            filters.notebookId == n.id,
            () {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(notebookId: n.id);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  void _showMethodFilter(BuildContext context, WidgetRef ref,
      SearchFilters filters, List<PaymentMethodModel> methods) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _filterSheet(
        title: 'Filter by Payment Method',
        children: [
          _sheetOption('All Methods', filters.paymentMethodId == null, () {
            ref.read(searchFiltersProvider.notifier).state =
                filters.copyWith(paymentMethodId: null);
            Navigator.pop(context);
          }),
          ...methods.map((m) => _sheetOption(
            m.name,
            filters.paymentMethodId == m.id,
            () {
              ref.read(searchFiltersProvider.notifier).state =
                  filters.copyWith(paymentMethodId: m.id);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  Future<void> _showDateFilter(
      BuildContext context, WidgetRef ref, SearchFilters filters) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filters.fromDate != null && filters.toDate != null
          ? DateTimeRange(start: filters.fromDate!, end: filters.toDate!)
          : null,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      ref.read(searchFiltersProvider.notifier).state = filters.copyWith(
        fromDate: range.start,
        toDate: range.end,
      );
    }
  }

  void _showAmountFilter(
      BuildContext context, WidgetRef ref, SearchFilters filters) {
    final minController = TextEditingController(
      text: filters.minAmount?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(
      text: filters.maxAmount?.toStringAsFixed(0) ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 20),
              Text('Filter by Amount',
                style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Min Amount',
                      labelStyle: GoogleFonts.inter(
                        color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor),
                      ),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Max Amount',
                      labelStyle: GoogleFonts.inter(
                        color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(searchFiltersProvider.notifier).state =
                            filters.copyWith(
                              minAmount: null,
                              maxAmount: null,
                            );
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Clear',
                        style: GoogleFonts.inter(
                          fontSize: 15, color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(searchFiltersProvider.notifier).state =
                            filters.copyWith(
                              minAmount: double.tryParse(minController.text),
                              maxAmount: double.tryParse(maxController.text),
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Apply',
                        style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterSheet({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Text(title,
            style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sheetOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimary,
                )),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded,
                color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}