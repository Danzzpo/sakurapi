// Lokasi: lib/features/budget/presentation/screens/tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../transaction/domain/models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_form_sheet.dart'; // Import form widget yang baru

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  String _formatRupiah(int amount) {
    String result = amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $result';
  }

  void _showBudgetForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bottom sheet bisa naik mengikuti keyboard
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const BudgetFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final budgets = budgetProvider.budgets;
    final transactions = txProvider.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        backgroundColor: AppColors.surface,
        actions: [
          // UI TERBARU: Mengganti ikon (+) dengan tombol teks "Atur" agar tidak bentrok dengan FAB
          TextButton.icon(
            onPressed: () => _showBudgetForm(context),
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            label: const Text('Atur', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: budgets.isEmpty
          ? const Center(child: Text('Belum ada anggaran yang diatur.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemCount: budgets.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final budget = budgets[index];

          int spent = 0;
          for (var tx in transactions) {
            if (tx.category == budget.category && tx.type == TransactionType.expense) {
              spent += tx.amount;
            }
          }

          final int remaining = budget.limitAmount - spent;
          final double progress = (spent / budget.limitAmount).clamp(0.0, 1.0);
          final bool isOverBudget = spent > budget.limitAmount;

          return _buildBudgetCard(budget.category, budget.limitAmount, spent, remaining, progress, isOverBudget);
        },
      ),
    );
  }

  Widget _buildBudgetCard(String category, int limit, int spent, int remaining, double progress, bool isOverBudget) {
    final Color progressColor = isOverBudget ? AppColors.error : (progress > 0.8 ? AppColors.warning : AppColors.primary);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Terpakai', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(_formatRupiah(spent), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Batas Anggaran', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(limit),
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}