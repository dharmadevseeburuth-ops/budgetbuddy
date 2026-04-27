class SavingsGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final int userId;

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'userId': userId,
    };
  }
}
