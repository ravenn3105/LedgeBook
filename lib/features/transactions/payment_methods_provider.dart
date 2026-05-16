import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/repositories/payment_method_repository.dart';

final paymentMethodRepositoryProvider = Provider((_) => PaymentMethodRepository());

final paymentMethodsProvider =
    AsyncNotifierProvider<PaymentMethodsNotifier, List<PaymentMethodModel>>(
        PaymentMethodsNotifier.new);

class PaymentMethodsNotifier extends AsyncNotifier<List<PaymentMethodModel>> {
  late PaymentMethodRepository _repo;

  @override
  Future<List<PaymentMethodModel>> build() async {
    _repo = ref.read(paymentMethodRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> addMethod(String name) async {
    final method = PaymentMethodModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.insert(method);
    ref.invalidateSelf();
  }

  Future<void> deleteMethod(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}