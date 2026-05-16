import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'tags_provider.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateTag(context, ref),
          ),
        ],
      ),
      body: tagsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tags) => tags.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label_off_rounded,
                      size: 48,
                      color: AppTheme.primaryColor.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No tags yet',
                      style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      )),
                    const SizedBox(height: 4),
                    Text('Tap + to create your first tag',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textMuted,
                      )),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tags.length,
                itemBuilder: (_, i) {
                  final tag = tags[i];
                  final color = tag.color != null
                      ? Color(tag.color!)
                      : AppTheme.primaryColor;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('#',
                            style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: color,
                            )),
                        ),
                      ),
                      title: Text(tag.name,
                        style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                      subtitle: Text(
                        '${tag.usageCount} uses',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textMuted,
                        )),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.textMuted, size: 20),
                        onPressed: () => _confirmDelete(context, ref, tag.id, tag.name),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showCreateTag(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    int selectedColor = 0xFF6C4FDB;

    final colors = [
      0xFF6C4FDB, 0xFF2196F3, 0xFF4CAF50, 0xFFFF9800,
      0xFFE91E63, 0xFF009688, 0xFFFF5722, 0xFF607D8B,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('New Tag',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.inter(
                    fontSize: 15, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tag name (e.g. food, travel)',
                    hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                    prefixText: '# ',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Color',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  )),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: colors.map((c) {
                      final isSelected = selectedColor == c;

                      return GestureDetector(
                        onTap: () => setModalState(
                          () => selectedColor = c,
                        ),

                        child: Container(
                          width: 32,
                          height: 32,

                          margin: const EdgeInsets.only(
                            right: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,

                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.textPrimary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),

                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;
                      await ref.read(tagsProvider.notifier)
                          .addTag(controller.text.trim(), selectedColor);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('Create Tag',
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete tag?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Remove "#$name" from all transactions?',
          style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              ref.read(tagsProvider.notifier).deleteTag(id);
              Navigator.pop(context);
            },
            child: Text('Delete',
              style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}