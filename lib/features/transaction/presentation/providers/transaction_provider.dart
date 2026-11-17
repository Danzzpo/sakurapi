import 'package:flutter/material.dart';
import '../../domain/models/transaction_model.dart'; // Import yang benar

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }
}