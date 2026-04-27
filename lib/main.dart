import 'dart:io';

import 'package:budgetbuddy/providers/auth_provider.dart';
import 'package:budgetbuddy/providers/savings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(BudgetBuddy());
}

class BudgetBuddy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BudgetBuddy',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
