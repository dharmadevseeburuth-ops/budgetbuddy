import 'dart:io';

import 'package:budgetbuddy/providers/auth_provider.dart';
import 'package:budgetbuddy/providers/savings_provider.dart';
import 'package:budgetbuddy/screens/home_screen.dart';
import 'package:budgetbuddy/screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
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
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),

        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user == null) {
              return StartScreen();
            }
            return HomeScreen();
          },
        ),
      ),
    );
  }
}
