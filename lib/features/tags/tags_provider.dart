import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/tag_model.dart';
import '../../data/repositories/tag_repository.dart';

final tagRepositoryProvider = Provider((_) => TagRepository());

final tagsProvider =
    AsyncNotifierProvider<TagsNotifier, List<TagModel>>(TagsNotifier.new);

class TagsNotifier extends AsyncNotifier<List<TagModel>> {
  late TagRepository _repo;

  @override
  Future<List<TagModel>> build() async {
    _repo = ref.read(tagRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> addTag(String name, int color) async {
    final tag = TagModel(
      id: const Uuid().v4(),
      name: name,
      color: color,
    );
    await _repo.insert(tag);
    ref.invalidateSelf();
  }

  Future<void> deleteTag(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}
