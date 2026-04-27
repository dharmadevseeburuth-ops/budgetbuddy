import 'package:budgetbuddy/providers/auth_provider.dart';
import 'package:budgetbuddy/providers/savings_provider.dart';
import 'package:budgetbuddy/screens/add_goal_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/set_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction.dart';
import 'stats_screen.dart';
import '../data/categories.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    await Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).loadTransactions(auth.user!.id!);

    await Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).loadBudgets(auth.user!.id!);

    await Provider.of<SavingsProvider>(
      context,
      listen: false,
    ).loadGoals(auth.user!.id!);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("BudgetBuddy"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text("Logout"),
                      onPressed: () {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).logout();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: 10),

          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    "Financial Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "Income: \$${provider.totalIncome}",
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),

                  Text(
                    "Expense: \$${provider.totalExpense}",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          Consumer<SavingsProvider>(
            builder: (context, savings, _) {
              final transactionProvider = Provider.of<TransactionProvider>(
                context,
              );

              if (savings.goals.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("No savings goals yet"),
                );
              }

              return Column(
                children: savings.goals.map((goal) {
                  double progress = 0;

                  if (goal.targetAmount > 0) {
                    progress =
                        (transactionProvider.totalSavings / goal.targetAmount) *
                        100;
                  }

                  if (progress > 100) progress = 100;

                  return Card(
                    child: ListTile(
                      title: Text(goal.title),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: progress / 100),
                          Text("${progress.toStringAsFixed(1)}% completed"),
                        ],
                      ),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\$${transactionProvider.totalSavings.toStringAsFixed(0)}",
                          ),
                          Text(
                            "/ \$${goal.targetAmount.toStringAsFixed(0)}",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          Expanded(
            child: provider.transactions.isEmpty
                ? Center(child: Text("No transactions yet"))
                : ListView.builder(
                    itemCount: provider.transactions.length,
                    itemBuilder: (_, i) {
                      var tx = provider.transactions[i];

                      bool overBudget = provider.isOverBudget(tx.category);

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: Text(
                            AppCategories.getIcon(tx.category),
                            style: TextStyle(fontSize: 22),
                          ),
                          title: Text(tx.title),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.category),

                              // BUDGET WARNING
                              if (overBudget)
                                Text(
                                  "Over Budget!",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),

                          trailing: Text(
                            "\$${tx.amount}",
                            style: TextStyle(
                              color: tx.type == "expense"
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add",
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTransactionScreen()),
              );

              await loadData();
            },
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "budget",
            child: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SetBudgetScreen()),
              );
            },
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "goal",
            child: Icon(Icons.flag),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddGoalScreen()),
              );

              await loadData(); // 🔥 refresh goals after adding
            },
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "stats",
            child: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsScreen()),
              );
            },
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
