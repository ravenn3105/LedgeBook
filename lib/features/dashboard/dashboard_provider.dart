import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/notebook_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/notebook_repository.dart';

class DashboardStats {
  final double totalBalance;
  final double monthIncome;
  final double monthExpenses;
  final List<TransactionModel> recentTransactions;
  final List<NotebookModel> recentNotebooks;
  final int currentStreak;
  final int longestStreak;
  final Map<String, double> weeklyExpenses;

  DashboardStats({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpenses,
    required this.recentTransactions,
    required this.recentNotebooks,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyExpenses,
  });
}

final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  final txRepo = TransactionRepository();
  final nbRepo = NotebookRepository();

  final allTx = await txRepo.getAll();
  final allNotebooks = await nbRepo.getAll();

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  // Monthly stats
  final monthTx = allTx.where((t) {
    final date = DateTime.fromMillisecondsSinceEpoch(t.date);
    return date.isAfter(monthStart.subtract(const Duration(seconds: 1)));
  }).toList();

  final monthIncome = monthTx
      .where((t) => t.type == 'cash_in')
      .fold(0.0, (sum, t) => sum + t.amount);

  final monthExpenses = monthTx
      .where((t) => t.type == 'cash_out')
      .fold(0.0, (sum, t) => sum + t.amount);

  // Total balance across all transactions
  final totalIn = allTx
      .where((t) => t.type == 'cash_in')
      .fold(0.0, (sum, t) => sum + t.amount);
  final totalOut = allTx
      .where((t) => t.type == 'cash_out')
      .fold(0.0, (sum, t) => sum + t.amount);

  // Weekly expenses (last 7 days)
  final Map<String, double> weeklyExpenses = {};
  for (int i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final key = _dayLabel(day);
    final dayExpenses = allTx.where((t) {
      final date = DateTime.fromMillisecondsSinceEpoch(t.date);
      return t.type == 'cash_out' &&
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).fold(0.0, (sum, t) => sum + t.amount);
    weeklyExpenses[key] = dayExpenses;
  }

  // Streak calculation
  final streaks = _calculateStreaks(allTx);

  return DashboardStats(
    totalBalance: totalIn - totalOut,
    monthIncome: monthIncome,
    monthExpenses: monthExpenses,
    recentTransactions: allTx.take(5).toList(),
    recentNotebooks: allNotebooks.take(4).toList(),
    currentStreak: streaks.$1,
    longestStreak: streaks.$2,
    weeklyExpenses: weeklyExpenses,
  );
});

String _dayLabel(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

(int, int) _calculateStreaks(List<TransactionModel> allTx) {
  if (allTx.isEmpty) return (0, 0);

  final now = DateTime.now();

  // Collect all days that had a cash_out
  final spendDays = allTx
      .where((t) => t.type == 'cash_out')
      .map((t) {
        final d = DateTime.fromMillisecondsSinceEpoch(t.date);
        return DateTime(d.year, d.month, d.day);
      })
      .toSet();

  // Current streak — count backwards from today
  int current = 0;
  for (int i = 0; i < 365; i++) {
    final day = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: i));
    if (spendDays.contains(day)) break;
    current++;
  }

  // Longest streak — find longest gap between spend days
  if (spendDays.isEmpty) {
    final firstTx = allTx.last;
    final firstDate = DateTime.fromMillisecondsSinceEpoch(firstTx.date);
    final days = now.difference(firstDate).inDays + 1;
    return (days, days);
  }

  final sortedSpendDays = spendDays.toList()..sort();
  int longest = current;
  int streak = 0;

  for (int i = 6; i >= 0; i--) {
    final day = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: i));
    if (!spendDays.contains(day)) {
      streak++;
      if (streak > longest) longest = streak;
    } else {
      streak = 0;
    }
  }

  // Also check gaps between spend days
  for (int i = 1; i < sortedSpendDays.length; i++) {
    final gap = sortedSpendDays[i]
        .difference(sortedSpendDays[i - 1])
        .inDays - 1;
    if (gap > longest) longest = gap;
  }

  return (current, longest);
}