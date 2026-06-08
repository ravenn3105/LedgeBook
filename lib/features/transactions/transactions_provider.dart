import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider((_) => TransactionRepository());

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
        TransactionsNotifier.new);

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  late TransactionRepository _repo;

  @override
  Future<List<TransactionModel>> build() async {
    _repo = ref.read(transactionRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> addTransaction({
    required String notebookId,
    required double amount,
    required String type,
    String? note,
    String? paymentMethodId,
    required DateTime date,
    required List<String> tagIds,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tx = TransactionModel(
      id: const Uuid().v4(),
      notebookId: notebookId,
      amount: amount,
      type: type,
      note: note,
      paymentMethodId: paymentMethodId,
      date: date.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.insert(tx, tagIds);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction({
    required TransactionModel transaction,
    required List<String> tagIds,
  }) async {
    final updated = TransactionModel(
      id: transaction.id,
      notebookId: transaction.notebookId,
      amount: transaction.amount,
      type: transaction.type,
      note: transaction.note,
      paymentMethodId: transaction.paymentMethodId,
      date: transaction.date,
      createdAt: transaction.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.update(updated, tagIds);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }

  Future<List<TransactionModel>> getByNotebook(String notebookId) async {
    return _repo.getByNotebook(notebookId);
  }
}