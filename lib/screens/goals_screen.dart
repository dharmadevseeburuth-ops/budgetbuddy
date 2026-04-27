import 'package:budgetbuddy/providers/savings_provider.dart';
import 'package:budgetbuddy/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, savings, _) {
        final transactionProvider = Provider.of<TransactionProvider>(context);

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
                  (transactionProvider.totalSavings / goal.targetAmount) * 100;
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
    );
  }
}
