import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dateRangeFilterProvider);
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Analytics')),
      body: Column(
        children: [
          _buildFilterBar(ref, filter),
          Expanded(
            child: analyticsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryRow(data),
                  const SizedBox(height: 16),
                  _buildIncomeExpenseChart(data),
                  const SizedBox(height: 16),
                  if (data.tagExpenses.isNotEmpty) ...[
                    _buildTagPieChart(data),
                    const SizedBox(height: 16),
                    _buildTagList(data),
                    const SizedBox(height: 16),
                  ],
                  _buildMonthlyChart(data),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(WidgetRef ref, DateRangeFilter current) {
    final filters = [
      (DateRangeFilter.today, 'Today'),
      (DateRangeFilter.thisWeek, 'Week'),
      (DateRangeFilter.thisMonth, 'Month'),
      (DateRangeFilter.lastMonth, 'Last Month'),
      (DateRangeFilter.allTime, 'All Time'),
    ];

    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = current == f.$1;
            return GestureDetector(
              onTap: () => ref
                  .read(dateRangeFilterProvider.notifier)
                  .state = f.$1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                  ),
                ),
                child: Text(f.$2,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(AnalyticsData data) {
    return Row(
      children: [
        Expanded(child: _summaryCard(
          'Income', data.totalIncome, Colors.green.shade500, Colors.green.shade50,
          Icons.arrow_downward_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard(
          'Expenses', data.totalExpenses, Colors.red.shade400, Colors.red.shade50,
          Icons.arrow_upward_rounded,
        )),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard(
          'Net', data.netBalance,
          data.netBalance >= 0 ? Colors.green.shade500 : Colors.red.shade400,
          data.netBalance >= 0 ? Colors.green.shade50 : Colors.red.shade50,
          Icons.account_balance_wallet_rounded,
        )),
      ],
    );
  }

  Widget _summaryCard(String label, double amount, Color color,
      Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(height: 8),
          Text(_fmt(amount),
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: 11, color: AppTheme.textSecondary,
            )),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(AnalyticsData data) {
    return _card(
      title: 'Income vs Expenses',
      child: SizedBox(
        height: 160,
        child: BarChart(
          BarChartData(
            maxY: [data.totalIncome, data.totalExpenses]
                .fold(0.0, (a, b) => a > b ? a : b) * 1.3 + 1,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final labels = ['Income', 'Expenses'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(labels[val.toInt()],
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textMuted,
                        )),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(
                  toY: data.totalIncome,
                  color: Colors.green.shade400,
                  width: 40,
                  borderRadius: BorderRadius.circular(8),
                ),
              ]),
              BarChartGroupData(x: 1, barRods: [
                BarChartRodData(
                  toY: data.totalExpenses,
                  color: Colors.red.shade400,
                  width: 40,
                  borderRadius: BorderRadius.circular(8),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagPieChart(AnalyticsData data) {
    final colors = [
      AppTheme.primaryColor,
      Colors.orange.shade400,
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
      Colors.amber.shade400,
      Colors.indigo.shade400,
    ];

    final entries = data.tagExpenses.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return _card(
      title: 'Spending by Category',
      child: SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: entries.asMap().entries.map((e) {
                    final pct = total > 0 ? e.value.value / total * 100 : 0;
                    return PieChartSectionData(
                      value: e.value.value,
                      color: colors[e.key % colors.length],
                      radius: 50,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[e.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              e.value.key,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList(AnalyticsData data) {
    final total = data.tagExpenses.values.fold(0.0, (s, v) => s + v);
    final sorted = data.tagExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _card(
      title: 'Category Breakdown',
      child: Column(
        children: sorted.map((e) {
          final pct = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(e.key,
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      )),
                    const Spacer(),
                    Text(_fmt(e.value),
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                    const SizedBox(width: 8),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.textMuted,
                      )),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyChart(AnalyticsData data) {
    final entries = data.monthlyComparison.entries.toList();
    final maxVal = entries
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);

    return _card(
      title: 'Monthly Comparison',
      child: SizedBox(
        height: 140,
        child: BarChart(
          BarChartData(
            maxY: maxVal == 0 ? 100 : maxVal * 1.3,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
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
                    color: AppTheme.primaryColor,
                    width: 32,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
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
          Text(title,
            style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _fmt(double amount) {
    return NumberFormat.currency(symbol: 'INR ', decimalDigits: 2)
        .format(amount);
  }
}