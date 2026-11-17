// Lokasi: lib/features/budget/presentation/providers/budget_provider.dart

import 'package:flutter/material.dart';
import '../../domain/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  // Kita beri 2 data awal (default) agar layar tidak kosong saat pertama dibuka
  final List<BudgetModel> _budgets = [
    BudgetModel(id: '1', category: 'Makanan & Minuman', limitAmount: 1500000),
    BudgetModel(id: '2', category: 'Transportasi', limitAmount: 500000),
  ];

  List<BudgetModel> get budgets => _budgets;

  void addBudget(BudgetModel budget) {
    // Jika kategori sudah ada anggarannya, kita timpa/update. Jika belum, kita tambah.
    final existingIndex = _budgets.indexWhere((b) => b.category == budget.category);
    if (existingIndex >= 0) {
      _budgets[existingIndex] = budget;
    } else {
      _budgets.add(budget);
    }
    notifyListeners();
  }
}