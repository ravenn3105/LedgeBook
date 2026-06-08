import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/tag_repository.dart';
import '../transactions/transactions_provider.dart';

enum DateRangeFilter { today, thisWeek, thisMonth, lastMonth, allTime }

class AnalyticsData {
  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
  final Map<String, double> tagExpenses;
  final Map<String, double> dailyExpenses;
  final Map<String, double> monthlyComparison;
  final List<TransactionModel> transactions;

  AnalyticsData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
    required this.tagExpenses,
    required this.dailyExpenses,
    required this.monthlyComparison,
    required this.transactions,
  });
}

final dateRangeFilterProvider =
    StateProvider<DateRangeFilter>((_) => DateRangeFilter.thisMonth);

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  // Watching transactionsProvider means this rebuilds automatically
  // whenever any transaction is added, edited, or deleted.
  ref.watch(transactionsProvider);

  final filter = ref.watch(dateRangeFilterProvider);
  final txRepo = TransactionRepository();
  final tagRepo = TagRepository();

  final now = DateTime.now();
  DateTime from;
  DateTime to = DateTime(now.year, now.month, now.day, 23, 59, 59);

  switch (filter) {
    case DateRangeFilter.today:
      from = DateTime(now.year, now.month, now.day);
      break;
    case DateRangeFilter.thisWeek:
      from = now.subtract(Duration(days: now.weekday - 1));
      from = DateTime(from.year, from.month, from.day);
      break;
    case DateRangeFilter.thisMonth:
      from = DateTime(now.year, now.month, 1);
      break;
    case DateRangeFilter.lastMonth:
      final lastMonth = DateTime(now.year, now.month - 1, 1);
      from = lastMonth;
      to = DateTime(now.year, now.month, 1)
          .subtract(const Duration(seconds: 1));
      break;
    case DateRangeFilter.allTime:
      from = DateTime(2020);
      break;
  }

  final transactions = await txRepo.getByDateRange(
    from.millisecondsSinceEpoch,
    to.millisecondsSinceEpoch,
  );

  final totalIncome = transactions
      .where((t) => t.type == 'cash_in')
      .fold(0.0, (s, t) => s + t.amount);

  final totalExpenses = transactions
      .where((t) => t.type == 'cash_out')
      .fold(0.0, (s, t) => s + t.amount);

  final Map<String, double> tagExpenses = {};

  for (final tx in transactions.where((t) => t.type == 'cash_out')) {
    final tags = await tagRepo.getForTransaction(tx.id);
    if (tags.isEmpty) {
      tagExpenses['Untagged'] =
          (tagExpenses['Untagged'] ?? 0) + tx.amount;
    } else {
      for (final tag in tags) {
        tagExpenses[tag.name] =
            (tagExpenses[tag.name] ?? 0) + tx.amount;
      }
    }
  }

  final Map<String, double> dailyExpenses = {};
  for (final tx in transactions.where((t) => t.type == 'cash_out')) {
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
    final key = '${date.day}/${date.month}';
    dailyExpenses[key] = (dailyExpenses[key] ?? 0) + tx.amount;
  }

  const monthNames = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final Map<String, double> monthlyComparison = {};
  for (int i = 3; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthEnd = DateTime(now.year, now.month - i + 1, 1)
        .subtract(const Duration(seconds: 1));
    final allTx = await txRepo.getByDateRange(
      month.millisecondsSinceEpoch,
      monthEnd.millisecondsSinceEpoch,
    );
    final expenses = allTx
        .where((t) => t.type == 'cash_out')
        .fold(0.0, (s, t) => s + t.amount);
    monthlyComparison[monthNames[month.month]] = expenses;
  }

  return AnalyticsData(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netBalance: totalIncome - totalExpenses,
    tagExpenses: tagExpenses,
    dailyExpenses: dailyExpenses,
    monthlyComparison: monthlyComparison,
    transactions: transactions,
  );
});