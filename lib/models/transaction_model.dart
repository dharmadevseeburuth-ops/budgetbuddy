class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String type; // income or expense
  final String category;
  final String date;
  final int userId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'userId': userId,
    };
  }
}