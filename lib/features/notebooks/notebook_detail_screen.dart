import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/notebook_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../transactions/add_transaction_screen.dart';

final _txRepoProvider = Provider((_) => TransactionRepository());

class NotebookDetailScreen extends ConsumerStatefulWidget {
  final NotebookModel notebook;
  const NotebookDetailScreen({super.key, required this.notebook});

  @override
  ConsumerState<NotebookDetailScreen> createState() =>
      _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends ConsumerState<NotebookDetailScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _saveLastNotebook();
    _loadTransactions();
  }

  Future<void> _saveLastNotebook() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_notebook_id', widget.notebook.id);
  }

  Future<void> _loadTransactions() async {
    final repo = ref.read(_txRepoProvider);
    final txs = await repo.getByNotebook(widget.notebook.id);
    if (mounted) setState(() { _transactions = txs; _loading = false; });
  }

  double get _totalIn => _transactions
      .where((t) => t.type == 'cash_in')
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalOut => _transactions
      .where((t) => t.type == 'cash_out')
      .fold(0, (sum, t) => sum + t.amount);

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      symbol: '${widget.notebook.currency} ',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.notebook.color != null
        ? Color(widget.notebook.color!)
        : AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.notebook.title),
        backgroundColor: AppTheme.backgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddTransactionSheet(
              preselectedNotebookId: widget.notebook.id,
            ),
          );
          _loadTransactions();
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Column(
              children: [
                // Summary card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        )),
                      const SizedBox(height: 4),
                      Text(_formatAmount(_totalIn - _totalOut),
                        style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _summaryTile('Income', _totalIn, true)),
                          const SizedBox(width: 12),
                          Expanded(child: _summaryTile('Expenses', _totalOut, false)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions list
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_rounded,
                                size: 48, color: color.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text('No transactions yet',
                                style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                )),
                              const SizedBox(height: 4),
                              Text('Tap + to add your first entry',
                                style: GoogleFonts.inter(
                                  fontSize: 13, color: AppTheme.textMuted,
                                )),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _transactions.length,
                          itemBuilder: (_, i) =>
                              _transactionTile(_transactions[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _summaryTile(String label, double amount, bool isIn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ]),
          const SizedBox(height: 4),
          Text(_formatAmount(amount),
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
            )),
        ],
      ),
    );
  }

  Widget _transactionTile(TransactionModel tx) {
    final isIn = tx.type == 'cash_in';
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isIn
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isIn ? Colors.green.shade500 : Colors.red.shade400,
              size: 20,
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
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy').format(date),
                  style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textMuted,
                  )),
              ],
            ),
          ),
          Text(
            '${isIn ? '+' : '-'}${_formatAmount(tx.amount)}',
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: isIn ? Colors.green.shade500 : Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}