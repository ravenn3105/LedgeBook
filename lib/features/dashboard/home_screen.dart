import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/notebook_model.dart';
import '../notebooks/notebook_detail_screen.dart';
import 'dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (stats) {
            return FutureBuilder<String>(
              future: SharedPreferences.getInstance()
                  .then((p) => p.getString('default_currency') ?? 'INR'),
              builder: (context, currSnap) {
                final currency = currSnap.data ?? 'INR';
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: () => ref.refresh(dashboardProvider.future),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      _buildBalanceCard(stats, currency),
                      const SizedBox(height: 16),
                      _buildMonthRow(stats, currency),
                      const SizedBox(height: 16),
                      _buildStreakCard(stats),
                      const SizedBox(height: 16),
                      _buildWeeklyChart(stats),
                      const SizedBox(height: 16),
                      _buildRecentNotebooks(context, stats.recentNotebooks),
                      const SizedBox(height: 16),
                      _buildRecentTransactions(stats.recentTransactions, currency),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17 ? 'Good afternoon' : 'Good evening';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greeting, style: GoogleFonts.inter(
              fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 2),
            Text('LedgeBook', style: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchScreen())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded,
              size: 18, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(DateFormat('MMM yyyy').format(DateTime.now()),
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  )),
                const SizedBox(width: 6),
                const Icon(Icons.settings_rounded,
                  size: 14, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(DashboardStats stats,String currency,) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C4FDB), Color(0xFF9B7FFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Balance',
            style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white70,
              fontWeight: FontWeight.w500,
            )),
          const SizedBox(height: 6),
          Text(_fmt(stats.totalBalance, currency),
            style: GoogleFonts.inter(
              fontSize: 32, fontWeight: FontWeight.w800,
              color: Colors.white,
            )),
          const SizedBox(height: 4),
          Text(
            stats.totalBalance >= 0
                ? 'You\'re in the green'
                : 'Expenses exceed income',
            style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(DashboardStats stats,String currency) {
    return Row(
      children: [
        Expanded(child: _statCard(
          'This Month In',
          _fmt(stats.monthIncome, currency),
          Icons.arrow_downward_rounded,
          Colors.green.shade500,
          Colors.green.shade50,
        )),
        const SizedBox(width: 12),
        Expanded(child: _statCard(
          'This Month Out',
          _fmt(stats.monthExpenses,currency),
          Icons.arrow_upward_rounded,
          Colors.red.shade400,
          Colors.red.shade50,
        )),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon,
      Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 10),
          Text(value,
            style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 12, color: AppTheme.textSecondary,
            )),
        ],
      ),
    );
  }

  Widget _buildStreakCard(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.currentStreak} day no-spend streak',
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Longest: ${stats.longestStreak} days',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(DashboardStats stats) {
    final entries = stats.weeklyExpenses.entries.toList();
    final maxVal = entries
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week',
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxVal == 0 ? 100 : maxVal * 1.3,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final label = entries[val.toInt()].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(label,
                            style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.textMuted,
                            )),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: entries.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: e.value.value > 0
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.15),
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotebooks(
      BuildContext context, List<NotebookModel> notebooks) {
    if (notebooks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notebooks',
          style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          )),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: notebooks.length,
            itemBuilder: (_, i) {
              final nb = notebooks[i];
              final color = nb.color != null
                  ? Color(nb.color!)
                  : AppTheme.primaryColor;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotebookDetailScreen(notebook: nb),
                  ),
                ),
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.book_rounded, color: color, size: 20),
                      Text(nb.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions,String currency) {
    if (transactions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
          style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          )),
        const SizedBox(height: 10),
        ...transactions.map((tx) {
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
                      Text(DateFormat('dd MMM').format(date),
                        style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textMuted,
                        )),
                    ],
                  ),
                ),
                Text(
                  '${isIn ? '+' : '-'}${_fmt(tx.amount, currency)}',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isIn ? Colors.green.shade500 : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _fmt(double amount, String currency) {
    return NumberFormat.currency(
      symbol: '$currency ',
      decimalDigits: 2,
    ).format(amount);
  }
}