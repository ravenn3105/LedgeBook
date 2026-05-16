import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/notebook_model.dart';
import '../../data/repositories/notebook_repository.dart';

final notebookRepositoryProvider = Provider((_) => NotebookRepository());

final notebooksProvider =
    AsyncNotifierProvider<NotebooksNotifier, List<NotebookModel>>(
        NotebooksNotifier.new);

class NotebooksNotifier extends AsyncNotifier<List<NotebookModel>> {
  late NotebookRepository _repo;

  @override
  Future<List<NotebookModel>> build() async {
    _repo = ref.read(notebookRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> addNotebook({
    required String title,
    String? description,
    String currency = 'INR',
    double? budget,
    String? icon,
    int? color,
  }) async {
    final notebook = NotebookModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      currency: currency,
      budget: budget,
      icon: icon,
      color: color,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _repo.insert(notebook);
    ref.invalidateSelf();
  }

  Future<void> updateNotebook(NotebookModel notebook) async {
    await _repo.update(notebook);
    ref.invalidateSelf();
  }

  Future<void> archiveNotebook(String id) async {
    await _repo.archive(id);
    ref.invalidateSelf();
  }

  Future<void> deleteNotebook(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}