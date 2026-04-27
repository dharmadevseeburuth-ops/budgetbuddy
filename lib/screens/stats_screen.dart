import 'package:budgetbuddy/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    double balance = provider.totalIncome - provider.totalExpense;

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Financial Dashboard",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 10),

          // SUMMARY CARDS
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                _buildCard("Income", provider.totalIncome, Colors.green),
                _buildCard("Expense", provider.totalExpense, Colors.red),
                _buildCard("Balance", balance, Colors.blue),
              ],
            ),
          ),

          SizedBox(height: 10),

          FinancialInsights(provider: provider),

          SizedBox(height: 10),

          // PIE CHART - SPENDING BREAKDOWN
          Text(
            "Spending Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10),

          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(provider),
                centerSpaceRadius: 50,
                sectionsSpace: 3,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),

          SizedBox(height: 20),

          // CATEGORY LIST (DETAILED VIEW)
          Text(
            "Category Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 10),

          ..._buildCategoryList(provider),
        ],
      ),
    );
  }

  // SUMMARY CARD WIDGET
  Widget _buildCard(String title, double value, Color color) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),

              SizedBox(height: 5),

              Text(
                "\$${value.toStringAsFixed(2)}",
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PIE CHART DATA
  List<PieChartSectionData> _buildPieSections(provider) {
    double income = provider.totalIncome;
    double expense = provider.totalExpense;
    double total = income + expense;

    return [
      PieChartSectionData(
        value: expense,
        title: "${((expense / total) * 100).toStringAsFixed(0)}%",
        color: Colors.red,
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: income,
        title: "${((income / total) * 100).toStringAsFixed(0)}%",
        color: Colors.green,
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  // CATEGORY BREAKDOWN
  List<Widget> _buildCategoryList(provider) {
    Map<String, double> categoryMap = {};

    for (var tx in provider.transactions) {
      if (tx.type == "expense") {
        categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
      }
    }

    return categoryMap.entries.map((e) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: Text(
            AppCategories.getIcon(e.key),
            style: TextStyle(fontSize: 22),
          ),
          title: Text(e.key),
          trailing: Text(
            "\$${e.value.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      );
    }).toList();
  }
}

class FinancialInsights extends StatelessWidget {
  final TransactionProvider provider;

  FinancialInsights({required this.provider});

  @override
  Widget build(BuildContext context) {
    double weeklyIncome = provider.getWeeklyIncome();
    double weeklyExpense = provider.getWeeklyExpense();

    double monthlyIncome = provider.getMonthlyIncome();
    double monthlyExpense = provider.getMonthlyExpense();

    return Column(
      children: [
        // WEEKLY CARD
        Card(
          child: ListTile(
            title: Text("Weekly Report"),
            subtitle: Text(
              "Income: \$${weeklyIncome.toStringAsFixed(0)}\n"
              "Expense: \$${weeklyExpense.toStringAsFixed(0)}\n"
              "Balance: \$${(weeklyIncome - weeklyExpense).toStringAsFixed(0)}",
            ),
          ),
        ),

        SizedBox(height: 10),

        // MONTHLY CARD
        Card(
          child: ListTile(
            title: Text("Monthly Report"),
            subtitle: Text(
              "Income: \$${monthlyIncome.toStringAsFixed(0)}\n"
              "Expense: \$${monthlyExpense.toStringAsFixed(0)}\n"
              "Balance: \$${(monthlyIncome - monthlyExpense).toStringAsFixed(0)}",
            ),
          ),
        ),
      ],
    );
  }
}
