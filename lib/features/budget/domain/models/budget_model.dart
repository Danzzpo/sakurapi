// Lokasi: lib/features/budget/domain/models/budget_model.dart

class BudgetModel {
  final String id;
  final String category;
  final int limitAmount; // Batas maksimal yang boleh dihabiskan

  BudgetModel({
    required this.id,
    required this.category,
    required this.limitAmount,
  });
}