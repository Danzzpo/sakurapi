enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final int amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type.name,
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      category: map['category'] ?? '',
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
            (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      note: map['note'],
    );
  }
}