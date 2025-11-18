import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider with ChangeNotifier {
  static const _expenseKey = 'custom_expense_categories';
  static const _incomeKey = 'custom_income_categories';

  final Set<String> _customExpenseCategories = {};
  final Set<String> _customIncomeCategories = {};

  CategoryProvider() {
    _loadCategories();
  }

  List<String> getCustomCategories(String type) {
    final target = type == 'expense'
        ? _customExpenseCategories
        : _customIncomeCategories;
    final sorted = target.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return List.unmodifiable(sorted);
  }

  bool containsCategory(String type, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final target = type == 'expense'
        ? _customExpenseCategories
        : _customIncomeCategories;
    return target.contains(trimmed);
  }

  Future<void> addCustomCategory(String type, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final target = type == 'expense'
        ? _customExpenseCategories
        : _customIncomeCategories;

    final added = target.add(trimmed);
    if (added) {
      await _saveCategories();
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenseJson = prefs.getString(_expenseKey);
      final incomeJson = prefs.getString(_incomeKey);

      if (expenseJson != null) {
        final List<dynamic> decoded = json.decode(expenseJson);
        _customExpenseCategories
          ..clear()
          ..addAll(decoded.cast<String>());
      }

      if (incomeJson != null) {
        final List<dynamic> decoded = json.decode(incomeJson);
        _customIncomeCategories
          ..clear()
          ..addAll(decoded.cast<String>());
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom categories: $e');
    }
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _expenseKey,
        json.encode(_customExpenseCategories.toList()..sort()),
      );
      await prefs.setString(
        _incomeKey,
        json.encode(_customIncomeCategories.toList()..sort()),
      );
    } catch (e) {
      debugPrint('Error saving custom categories: $e');
    }
  }
}
