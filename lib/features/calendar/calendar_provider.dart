import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../transactions/transactions_provider.dart';

class CalendarData {
  final Map<DateTime, List<TransactionModel>> transactionsByDay;
  final Map<DateTime, double> dailyNet;

  CalendarData({
    required this.transactionsByDay,
    required this.dailyNet,
  });
}

final calendarMonthProvider =
    StateProvider<DateTime>((_) => DateTime.now());

final calendarProvider = FutureProvider<CalendarData>((ref) async {
  // Watching transactionsProvider means this rebuilds automatically
  // whenever any transaction is added, edited, or deleted.
  ref.watch(transactionsProvider);

  final month = ref.watch(calendarMonthProvider);
  final repo = TransactionRepository();

  final from = DateTime(month.year, month.month, 1);
  final to = DateTime(month.year, month.month + 1, 1)
      .subtract(const Duration(seconds: 1));

  final transactions = await repo.getByDateRange(
    from.millisecondsSinceEpoch,
    to.millisecondsSinceEpoch,
  );

  final Map<DateTime, List<TransactionModel>> byDay = {};
  final Map<DateTime, double> dailyNet = {};

  for (final tx in transactions) {
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
    final key = DateTime(date.year, date.month, date.day);

    byDay.putIfAbsent(key, () => []).add(tx);

    final amount = tx.type == 'cash_in' ? tx.amount : -tx.amount;
    dailyNet[key] = (dailyNet[key] ?? 0) + amount;
  }

  return CalendarData(
    transactionsByDay: byDay,
    dailyNet: dailyNet,
  );
});

final selectedDayProvider = StateProvider<DateTime?>((_) => null);