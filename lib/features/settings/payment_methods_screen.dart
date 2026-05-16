import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../transactions/payment_methods_provider.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddMethod(context, ref),
          ),
        ],
      ),
      body: methodsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (methods) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: methods.length,
          itemBuilder: (_, i) {
            final method = methods[i];
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payment_rounded,
                    color: AppTheme.primaryColor, size: 18),
                ),
                title: Text(method.name,
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  )),
                trailing: method.isDefault
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Default',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          )),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                          color: AppTheme.textMuted, size: 20),
                        onPressed: () => ref
                            .read(paymentMethodsProvider.notifier)
                            .deleteMethod(method.id),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddMethod(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
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
              Text('New Payment Method',
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
                  hintText: 'e.g. PayPal, Crypto',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    await ref
                        .read(paymentMethodsProvider.notifier)
                        .addMethod(controller.text.trim());
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text('Add Method',
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
    );
  }
}