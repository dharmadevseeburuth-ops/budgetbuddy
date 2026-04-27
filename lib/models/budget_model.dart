class BudgetModel {
  final String category;
  final double budgetLimit;
  final int userId;

  BudgetModel({
    required this.category,
    required this.budgetLimit,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'budgetLimit': budgetLimit,
      'userId': userId,
    };
  }
}