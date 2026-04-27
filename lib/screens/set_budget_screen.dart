import 'package:budgetbuddy/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_helper.dart';
import '../models/budget_model.dart';

class SetBudgetScreen extends StatefulWidget {
  @override
  _SetBudgetScreenState createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  String category = "Food";
  final limitController = TextEditingController();
  DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text("Set Budget")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: category,
              items: AppCategories.all.map((c) {
                return DropdownMenuItem(
                  value: c.name,
                  child: Text("${c.icon} ${c.name}"),
                );
              }).toList(),
              onChanged: (val) => setState(() => category = val!),
            ),

            TextField(
              controller: limitController,
              decoration: InputDecoration(labelText: "Budget Limit"),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await dbHelper.setBudget(
                  BudgetModel(
                    category: category,
                    budgetLimit: double.parse(limitController.text),
                    userId: user.id!,
                  ),
                );

                Navigator.pop(context);
              },
              child: Text("Save Budget"),
            )
          ],
        ),
      ),
    );
  }
}