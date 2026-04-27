import '../models/category_model.dart';

class AppCategories {
  static final List<CategoryModel> all = [
    CategoryModel(name: "Food", icon: "🍔"),
    CategoryModel(name: "Transport", icon: "🚗"),
    CategoryModel(name: "Bills", icon: "💡"),
    CategoryModel(name: "Entertainment", icon: "🎮"),
    CategoryModel(name: "Shopping", icon: "🛍️"),
    CategoryModel(name: "Health", icon: "💊"),
  ];

  static String getIcon(String name) {
    return all.firstWhere(
      (c) => c.name == name,
      orElse: () => CategoryModel(name: "Other", icon: "📦"),
    ).icon;
  }
}