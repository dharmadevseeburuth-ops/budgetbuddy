import '../models/category_model.dart';

class AppCategories {

  // EXPENSE CATEGORIES
  static final List<CategoryModel> expenseCategories = [
    CategoryModel(name: "Food", icon: "🍔"),
    CategoryModel(name: "Transport", icon: "🚗"),
    CategoryModel(name: "Bills", icon: "💡"),
    CategoryModel(name: "Entertainment", icon: "🎮"),
    CategoryModel(name: "Shopping", icon: "🛍️"),
    CategoryModel(name: "Health", icon: "💊"),
    CategoryModel(name: "Other", icon: "📦"),
  ];

  // INCOME CATEGORIES
  static final List<CategoryModel> incomeCategories = [
    CategoryModel(name: "Salary", icon: "💼"),
    CategoryModel(name: "Freelance", icon: "💻"),
    CategoryModel(name: "Other Income", icon: "💰"),
  ];

  // GET ICON (works for both)
  static String getIcon(String name) {
    final all = [...expenseCategories, ...incomeCategories];

    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => CategoryModel(name: "Other", icon: "📦"),
    ).icon;
  }

  // GET CATEGORIES BY TYPE
  static List<CategoryModel> getByType(String type) {
    if (type == "income") {
      return incomeCategories;
    } else {
      return expenseCategories;
    }
  }
}