import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/savings_goal_model.dart';

class AddGoalScreen extends StatefulWidget {
  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text("Add Savings Goal")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Goal Title"),
            ),

            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Target Amount"),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final goal = SavingsGoal(
                  title: titleController.text,
                  targetAmount: double.parse(amountController.text),
                  savedAmount: 0,
                  userId: user.id!,
                );

                await Provider.of<SavingsProvider>(
                  context,
                  listen: false,
                ).addGoal(goal);

                Navigator.pop(context);
              },
              child: Text("Save Goal"),
            ),
          ],
        ),
      ),
    );
  }
}
