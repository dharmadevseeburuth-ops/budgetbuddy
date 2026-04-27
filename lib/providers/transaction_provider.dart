import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  Map<String, double> budgetLimits = {};
  DBHelper dbHelper = DBHelper();

  List<TransactionModel> get transactions => _transactions;

  List<TransactionModel> getWeeklyTransactions() {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(Duration(days: 7));

    return _transactions.where((tx) {
      DateTime date = DateTime.parse(tx.date);
      return date.isAfter(weekAgo);
    }).toList();
  }

  List<TransactionModel> getMonthlyTransactions() {
    DateTime now = DateTime.now();
    DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);

    return _transactions.where((tx) {
      DateTime date = DateTime.parse(tx.date);
      return date.isAfter(monthAgo);
    }).toList();
  }

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

  double getCategorySpent(String category) {
    return _transactions
        .where((tx) => tx.category == category && tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  bool isOverBudget(String category) {
    double spent = getCategorySpent(category);
    double limit = budgetLimits[category] ?? 0;

    if (limit == 0) return false;

    return spent > limit;
  }

  double get totalSavings {
    double savings = totalIncome - totalExpense;
    return savings < 0 ? 0 : savings;
  }

  String? getSpendingAlert(String category) {
    double spent = _transactions
        .where((tx) => tx.category == category && tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);

    double limit = budgetLimits[category] ?? 0;

    if (limit == 0) return null;

    if (spent >= limit) {
      return "🚨 You exceeded your $category budget!";
    }

    if (spent >= limit * 0.8) {
      return "⚠️ You're close to your $category budget";
    }

    return null;
  }

  String getRecommendation(String category) {
    switch (category) {
      case "Food":
        return "Try cooking at home more often 🍳";
      case "Transport":
        return "Consider public transport or carpool 🚗";
      case "Entertainment":
        return "Look for free or low-cost activities 🎮";
      case "Shopping":
        return "Avoid impulse purchases 🛍️";
      case "Bills":
        return "Reduce electricity usage 💡";
      default:
        return "Track your spending carefully";
    }
  }

  double getWeeklyIncome() {
    return getWeeklyTransactions()
        .where((tx) => tx.type == "income")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double getWeeklyExpense() {
    return getWeeklyTransactions()
        .where((tx) => tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double getMonthlyIncome() {
    return getMonthlyTransactions()
        .where((tx) => tx.type == "income")
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  double getMonthlyExpense() {
    return getMonthlyTransactions()
        .where((tx) => tx.type == "expense")
        .fold(0, (sum, tx) => sum + tx.amount);
  }
}
