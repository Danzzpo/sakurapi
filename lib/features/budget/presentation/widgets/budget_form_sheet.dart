// Lokasi: lib/features/budget/presentation/widgets/budget_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/models/budget_model.dart';
import '../providers/budget_provider.dart';

// Formatter titik ribuan (sama seperti di transaksi manual)
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');
    String formatted = cleanText.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({super.key});

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  final TextEditingController _limitController = TextEditingController();
  String _selectedCategory = 'Makanan & Minuman';

  // Daftar kategori pengeluaran yang bisa dianggarkan
  final List<String> _expenseCategories = [
    'Makanan & Minuman', 'Transportasi', 'Kebutuhan Pokok',
    'Tagihan & Utilitas', 'Hiburan & Jajan', 'Kesehatan', 'Pendidikan', 'Lainnya'
  ];

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batas anggaran tidak boleh kosong')));
      return;
    }

    final String cleanAmount = _limitController.text.replaceAll('.', '');
    final int limitAmount = int.tryParse(cleanAmount) ?? 0;

    if (limitAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anggaran harus lebih dari 0')));
      return;
    }

    // Buat model anggaran baru
    final newBudget = BudgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      limitAmount: limitAmount,
    );

    // Simpan ke Provider
    context.read<BudgetProvider>().addBudget(newBudget);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anggaran berhasil diperbarui!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context); // Tutup Bottom Sheet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding dinamis agar form tidak tertutup keyboard
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 24),
          const Text('Atur Batas Anggaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),

          const Text('Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                items: _expenseCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedCategory = newValue);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Batas Maksimal (Rp)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CurrencyInputFormatter()],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '0',
              prefixText: 'Rp ',
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(text: 'Simpan Anggaran', onPressed: _saveBudget),
        ],
      ),
    );
  }
}