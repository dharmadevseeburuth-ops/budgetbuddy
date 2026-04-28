import 'package:budgetbuddy/providers/auth_provider.dart';
import 'package:budgetbuddy/providers/savings_provider.dart';
import 'package:budgetbuddy/screens/add_goal_screen.dart';
import 'package:budgetbuddy/screens/goals_screen.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:budgetbuddy/screens/set_budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'stats_screen.dart';
import '../data/categories.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadData();
      checkOverspendingAlerts();
    });
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

  void checkOverspendingAlerts() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    for (var category in provider.budgetLimits.keys) {
      final alert = provider.getSpendingAlert(category);

      if (alert != null && alert.contains("exceeded")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(alert), backgroundColor: Colors.red),
        );
        break;
      }
    }
  }

  void showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add Transaction"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTransactionScreen()),
                );
                await loadData();
              },
            ),

            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text("Set Budget"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SetBudgetScreen()),
                );
                await loadData();
              },
            ),

            ListTile(
              leading: Icon(Icons.flag),
              title: Text("Add Goal"),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddGoalScreen()),
                );
                await loadData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [HomeContent(), StatsScreen(), GoalsScreen()];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BudgetBuddy",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        automaticallyImplyLeading: false,
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

      body: screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          if (index == 3) {
            showQuickActions();
            return;
          }

          setState(() => _selectedIndex = index);

          if (index == 0) {
            await loadData();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Actions",
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions.reversed.toList();

    return Column(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

        Text(
          "Budget Overview",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),

        Card(
          margin: EdgeInsets.all(10),
          child: provider.budgetLimits.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      "No budgets set yet",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: provider.budgetLimits.entries.map((entry) {
                    String category = entry.key;
                    double limit = entry.value;

                    double spent = provider.getCategorySpent(category);

                    double percent = limit > 0 ? (spent / limit) : 0;
                    if (percent > 1) percent = 1;

                    return ListTile(
                      leading: Text(AppCategories.getIcon(category)),
                      title: Text(category),
                      subtitle: LinearProgressIndicator(value: percent),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${spent.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}",
                          ),
                          if (provider.isOverBudget(category))
                            Text(
                              "Over Budget!",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),

        Text(
          "Transactions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),

        Expanded(
          child: transactions.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      "No transactions yet",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (_, i) {
                    var tx = transactions[i];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

                            Builder(
                              builder: (context) {
                                final alert = provider.getSpendingAlert(
                                  tx.category,
                                );

                                if (alert != null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert,
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),

                                      Text(
                                        provider.getRecommendation(tx.category),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return SizedBox();
                              },
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
    );
  }
}
