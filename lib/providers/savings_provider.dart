import 'package:flutter/material.dart';
import '../models/savings_goal_model.dart';
import '../services/db_helper.dart';

class SavingsProvider with ChangeNotifier {
  List<SavingsGoal> _goals = [];
  DBHelper dbHelper = DBHelper();

  List<SavingsGoal> get goals => _goals;

  Future<void> loadGoals(int userId) async {
    _goals = await dbHelper.fetchGoals(userId);
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await dbHelper.insertGoal(goal);
    await loadGoals(goal.userId);
  }

  double getProgress(SavingsGoal goal, double totalSavings) {
    return (totalSavings / goal.targetAmount) * 100;
  }
}
