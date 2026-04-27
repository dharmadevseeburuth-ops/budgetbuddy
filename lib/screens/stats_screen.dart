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

    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Dashboard"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

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

            // PIE CHART - SPENDING BREAKDOWN
            Text(
              "Spending Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(provider),
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            SizedBox(height: 20),

            // CATEGORY LIST (DETAILED VIEW)
            Text(
              "Category Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            ..._buildCategoryList(provider),
          ],
        ),
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
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold)),

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
    return [
      PieChartSectionData(
        value: provider.totalExpense,
        title: "Expense",
        color: Colors.red,
        radius: 60,
      ),
      PieChartSectionData(
        value: provider.totalIncome,
        title: "Income",
        color: Colors.green,
        radius: 60,
      ),
    ];
  }

  // CATEGORY BREAKDOWN
  List<Widget> _buildCategoryList(provider) {
    Map<String, double> categoryMap = {};

    for (var tx in provider.transactions) {
      if (tx.type == "expense") {
        categoryMap[tx.category] =
            (categoryMap[tx.category] ?? 0) + tx.amount;
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      );
    }).toList();
  }
}