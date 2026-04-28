import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../data/categories.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String type = "expense";
  String selectedCategory = AppCategories.expenseCategories.first.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transaction")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),

              SizedBox(height: 10),

              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: type,
                items: ["income", "expense"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    type = val!;
                  });
                },
                decoration: InputDecoration(labelText: "Type"),
              ),

              SizedBox(height: 25),

              DropdownButtonFormField<String>(
                value: AppCategories.getByType(type)
                        .any((c) => c.name == selectedCategory)
                    ? selectedCategory
                    : AppCategories.getByType(type).first.name,

                items: AppCategories.getByType(type)
                    .toSet()
                    .map((c) => DropdownMenuItem(
                          value: c.name,
                          child: Text("${c.icon} ${c.name}"),
                        ))
                    .toList(),

                onChanged: (val) {
                  setState(() {
                    selectedCategory = val!;
                  });
                },
                decoration: InputDecoration(labelText: "Category"),
              ),

              SizedBox(height: 15),

              ElevatedButton(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);

                  final tx = TransactionModel(
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? 0,
                    category: selectedCategory,
                    type: type,
                    date: DateTime.now().toString(),
                    userId: auth.user!.id!,
                  );

                  await Provider.of<TransactionProvider>(context, listen: false)
                      .addTransaction(tx);

                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}