import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/user_model.dart';
import '../utils/password_helper.dart';
import '../utils/validation_helper.dart';

class AuthProvider with ChangeNotifier {
  DBHelper dbHelper = DBHelper();
  UserModel? _user;

  UserModel? get user => _user;

  // LOGIN
  Future<bool> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return false;
      }

      final hashedPassword = PasswordHelper.hashPassword(password);

      final result = await dbHelper.loginUser(email, hashedPassword);

      if (result != null) {
        _user = result;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  // REGISTER
  Future<String> register(String email, String password) async {
    try {
      // empty check
      if (email.isEmpty || password.isEmpty) return "invalid";

      // email format validation
      if (!ValidationHelper.isValidEmail(email)) {
        return "email_invalid";
      }

      final exists = await dbHelper.userExists(email);
      if (exists) return "exists";

      final hashedPassword = PasswordHelper.hashPassword(password);

      await dbHelper.registerUser(
        UserModel(email: email, password: hashedPassword),
      );

      return "success";
    } catch (e) {
      print("REGISTER ERROR: $e");
      return "error";
    }
  }

  // LOGOUT
  void logout() {
    _user = null;
    notifyListeners();
  }
}