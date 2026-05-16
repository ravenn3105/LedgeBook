import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final calendarAsync = ref.watch(calendarProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () {
              ref.read(calendarMonthProvider.notifier).state = DateTime.now();
              ref.read(selectedDayProvider.notifier).state = null;
            },
          ),
        ],
      ),
      body: calendarAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => Column(
          children: [
            // Month navigator
            _buildMonthNavigator(ref, month),

            // Weekday headers
            _buildWeekdayHeader(),

            // Calendar grid
            _buildCalendarGrid(ref, month, data, selectedDay),

            const Divider(height: 1, color: AppTheme.borderColor),

            // Day detail
            Expanded(
              child: selectedDay == null
                  ? _buildMonthSummary(data)
                  : _buildDayDetail(selectedDay, data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigator(WidgetRef ref, DateTime month) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: AppTheme.textPrimary,
            onPressed: () {
              ref.read(calendarMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1);
              ref.read(selectedDayProvider.notifier).state = null;
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM yyyy').format(month),
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            color: AppTheme.textPrimary,
            onPressed: () {
              ref.read(calendarMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1);
              ref.read(selectedDayProvider.notifier).state = null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      )),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    WidgetRef ref,
    DateTime month,
    CalendarData data,
    DateTime? selectedDay,
  ) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    // Offset so Monday = 0
    final startOffset = (firstDay.weekday - 1) % 7;
    final totalCells = startOffset + lastDay.day;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;

              if (dayNum < 1 || dayNum > lastDay.day) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final date = DateTime(month.year, month.month, dayNum);
              final key = DateTime(date.year, date.month, date.day);
              final hasTx = data.transactionsByDay.containsKey(key);
              final net = data.dailyNet[key] ?? 0;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = selectedDay != null &&
                  selectedDay.year == date.year &&
                  selectedDay.month == date.month &&
                  selectedDay.day == date.day;

              Color? dotColor;
              if (hasTx) {
                dotColor = net > 0 ? Colors.green.shade400 : Colors.red.shade400;
                if (net == 0) dotColor = Colors.orange.shade400;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedDayProvider.notifier).state =
                        isSelected ? null : date;
                  },
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isToday
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$dayNum',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimary,
                          )),
                        if (hasTx && dotColor != null)
                          Container(
                            width: 5, height: 5,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildMonthSummary(CalendarData data) {
    final totalDays = data.transactionsByDay.length;
    final spendDays = data.dailyNet.values.where((v) => v < 0).length;
    final noSpendDays = totalDays - spendDays;
    final totalIn = data.transactionsByDay.values
        .expand((txs) => txs)
        .where((t) => t.type == 'cash_in')
        .fold(0.0, (s, t) => s + t.amount);
    final totalOut = data.transactionsByDay.values
        .expand((txs) => txs)
        .where((t) => t.type == 'cash_out')
        .fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Month Overview',
          style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _overviewTile(
              'Active Days', '$totalDays',
              Icons.calendar_today_rounded, AppTheme.primaryColor,
            )),
            const SizedBox(width: 10),
            Expanded(child: _overviewTile(
              'No-Spend Days', '$noSpendDays',
              Icons.local_fire_department_rounded, Colors.orange.shade400,
            )),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _overviewTile(
              'Total In', _fmt(totalIn),
              Icons.arrow_downward_rounded, Colors.green.shade500,
            )),
            const SizedBox(width: 10),
            Expanded(child: _overviewTile(
              'Total Out', _fmt(totalOut),
              Icons.arrow_upward_rounded, Colors.red.shade400,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Text('Tap any day to see details',
          style: GoogleFonts.inter(
            fontSize: 13, color: AppTheme.textMuted,
          )),
      ],
    );
  }

  Widget _overviewTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
                Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.textSecondary,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetail(DateTime day, CalendarData data) {
    final key = DateTime(day.year, day.month, day.day);
    final transactions = data.transactionsByDay[key] ?? [];
    final net = data.dailyNet[key] ?? 0;

    final totalIn = transactions
        .where((t) => t.type == 'cash_in')
        .fold(0.0, (s, t) => s + t.amount);
    final totalOut = transactions
        .where((t) => t.type == 'cash_out')
        .fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(DateFormat('dd MMMM yyyy').format(day),
              style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              )),
            const Spacer(),
            if (transactions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: net >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${net >= 0 ? '+' : ''}${_fmt(net)}',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: net >= 0
                        ? Colors.green.shade600
                        : Colors.red.shade500,
                  ),
                ),
              ),
          ],
        ),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Text('No transactions on this day',
                style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textMuted,
                )),
            ),
          )
        else ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dayStatChip(
                'In', _fmt(totalIn), Colors.green.shade500)),
              const SizedBox(width: 8),
              Expanded(child: _dayStatChip(
                'Out', _fmt(totalOut), Colors.red.shade400)),
            ],
          ),
          const SizedBox(height: 12),
          ...transactions.map((tx) {
            final isIn = tx.type == 'cash_in';
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isIn ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      isIn
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: isIn
                          ? Colors.green.shade500
                          : Colors.red.shade400,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tx.note ?? (isIn ? 'Income' : 'Expense'),
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      )),
                  ),
                  Text(
                    '${isIn ? '+' : '-'}${_fmt(tx.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isIn
                          ? Colors.green.shade500
                          : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _dayStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('$label  ',
            style: GoogleFonts.inter(
              fontSize: 12, color: color, fontWeight: FontWeight.w600,
            )),
          Expanded(
            child: Text(value,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              )),
          ),
        ],
      ),
    );
  }

  String _fmt(double amount) {
    return NumberFormat.currency(symbol: 'INR ', decimalDigits: 0)
        .format(amount);
  }
}