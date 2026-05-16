import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';


class SearchFilters {
  final String query;
  final String? notebookId;
  final String? type;
  final String? paymentMethodId;
  final double? minAmount;
  final double? maxAmount;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SearchFilters({
    this.query = '',
    this.notebookId,
    this.type,
    this.paymentMethodId,
    this.minAmount,
    this.maxAmount,
    this.fromDate,
    this.toDate,
  });

  SearchFilters copyWith({
    String? query,
    String? notebookId,
    bool clearNotebookId = false,
    String? type,
    bool clearType = false,
    String? paymentMethodId,
    bool clearPaymentMethodId = false,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    DateTime? fromDate,
    bool clearFromDate = false,
    DateTime? toDate,
    bool clearToDate = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,

      notebookId: clearNotebookId
          ? null
          : notebookId ?? this.notebookId,

      type: clearType
          ? null
          : type ?? this.type,

      paymentMethodId: clearPaymentMethodId
          ? null
          : paymentMethodId ?? this.paymentMethodId,

      minAmount: clearMinAmount
          ? null
          : minAmount ?? this.minAmount,

      maxAmount: clearMaxAmount
          ? null
          : maxAmount ?? this.maxAmount,

      fromDate: clearFromDate
          ? null
          : fromDate ?? this.fromDate,

      toDate: clearToDate
          ? null
          : toDate ?? this.toDate,
    );
  }

  bool get hasActiveFilters {
    return notebookId != null ||
        type != null ||
        paymentMethodId != null ||
        minAmount != null ||
        maxAmount != null ||
        fromDate != null ||
        toDate != null;
  }
}

final searchFiltersProvider =
    StateProvider<SearchFilters>(
  (_) => const SearchFilters(),
);

final searchResultsProvider =
    FutureProvider<List<TransactionModel>>(
  (ref) async {
    final filters = ref.watch(searchFiltersProvider);

    final repo = TransactionRepository();

    return repo.search(
      query: filters.query.isEmpty
          ? null
          : filters.query,

      notebookId: filters.notebookId,

      type: filters.type,

      paymentMethodId: filters.paymentMethodId,

      minAmount: filters.minAmount,

      maxAmount: filters.maxAmount,

      fromDate:
          filters.fromDate?.millisecondsSinceEpoch,

      toDate:
          filters.toDate?.millisecondsSinceEpoch,
    );
  },
);