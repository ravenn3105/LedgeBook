import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/notebook_model.dart';
import 'notebooks_provider.dart';
import 'create_notebook_sheet.dart';
import 'notebook_detail_screen.dart';

class NotebooksScreen extends ConsumerWidget {
  const NotebooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooksAsync = ref.watch(notebooksProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notebooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateNotebookSheet(),
            ),
          ),
        ],
      ),
      body: notebooksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notebooks) => notebooks.isEmpty
            ? _buildEmpty(context)
            : _buildList(context, ref, notebooks),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book_rounded,
                color: AppTheme.primaryColor, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No notebooks yet',
            style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 6),
          Text('Tap + to create your first notebook',
            style: GoogleFonts.inter(
              fontSize: 14, color: AppTheme.textSecondary,
            )),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<NotebookModel> notebooks,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notebooks.length,
      itemBuilder: (context, index) {
        final notebook = notebooks[index];

        final color = notebook.color != null
            ? Color(notebook.color!)
            : AppTheme.primaryColor;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotebookDetailScreen(
                notebook: notebook,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              title: Text(
                notebook.title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: notebook.description != null
                  ? Text(
                      notebook.description!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : Text(
                      notebook.currency,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Net amount badge
                  Builder(builder: (context) {
                    final net = ref.watch(
                      notebookNetAmountProvider(notebook.id),
                    );
                    final isPositive = net >= 0;
                    final color = isPositive
                        ? AppTheme.successColor
                        : AppTheme.errorColor;
                    final sign = isPositive ? '+' : '';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$sign${net.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    );
                  }),
                  // Popup menu
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.textMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text(
                          'Archive',
                          style: GoogleFonts.inter(),
                        ),
                        onTap: () => ref
                            .read(notebooksProvider.notifier)
                            .archiveNotebook(notebook.id),
                      ),
                      PopupMenuItem(
                        child: Text(
                          'Delete',
                          style: GoogleFonts.inter(
                            color: Colors.red,
                          ),
                        ),
                        onTap: () => ref
                            .read(notebooksProvider.notifier)
                            .deleteNotebook(notebook.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}