import 'package:budgetbuddy/models/budget_model.dart';
import 'package:budgetbuddy/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), 'budget.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT,
            userId INTEGER
          )
        ''');

        await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          budgetLimit REAL,
          userId INTEGER
        )
        ''');
      },
    );
  }

  Future<int> registerUser(UserModel user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final dbClient = await db;

    final result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final e = result.first;
      return UserModel(
        id: e['id'] as int,
        email: e['email'] as String,
        password: e['password'] as String,
      );
    }

  return null;
  }

  Future<bool> userExists(String email) async {
    final dbClient = await db;

    final result = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<int> setBudget(BudgetModel budget) async {
    final dbClient = await db;

    return await dbClient.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getBudgets(int userId) async {
    final dbClient = await db;

    return await dbClient.query(
      'budgets',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> insert(TransactionModel tx) async {
    final dbClient = await db;
    return await dbClient.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> fetch(int userId) async {
    final dbClient = await db;

    final maps = await dbClient.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((e) => TransactionModel(
      id: e['id'] as int,
      title: e['title'] as String,
      amount: (e['amount'] as num).toDouble(),
      type: e['type'] as String,
      category: e['category'] as String,
      date: e['date'] as String,
      userId: e['userId'] as int,
    )).toList();
  }
}