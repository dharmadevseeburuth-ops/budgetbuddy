import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  Map<String, double> budgetLimits = {};
  DBHelper dbHelper = DBHelper();

  List<TransactionModel> get transactions => _transactions;

  Future<void> loadTransactions(int userId) async {
    _transactions = await dbHelper.fetch(userId);
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await dbHelper.insert(tx);
    await loadTransactions(tx.userId);
  }

  Future<void> loadBudgets(int userId) async {
    final data = await dbHelper.getBudgets(userId);

    budgetLimits.clear();

    for (var b in data) {
      budgetLimits[b['category']] = (b['budgetLimit'] as num).toDouble();
    }

    notifyListeners();
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == "income")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  bool isOverBudget(String category) {
    double spent = _transactions
        .where((tx) => tx.category == category && tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);

    double budgetLimit = budgetLimits[category] ?? 0;

    return budgetLimit > 0 && spent > budgetLimit;
  }

  double get totalSavings {
    double savings = totalIncome - totalExpense;
    return savings < 0 ? 0 : savings;
  }
}
