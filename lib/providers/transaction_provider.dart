import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => [..._transactions];
  List<Transaction> get sortedTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  bool get isLoading => _isLoading;

  double get balance {
    double income = 0;
    double expense = 0;
    for (var transaction in _transactions) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    return income - expense;
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<Transaction> get recentTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString('transactions');

      if (transactionsJson != null) {
        final List<dynamic> decodedData = json.decode(transactionsJson);
        _transactions =
            decodedData.map((item) => Transaction.fromJson(item)).toList();
      } else {
        _transactions = [];
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString('transactions', transactionsJson);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    final index =
        _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  Future<void> resetData() async {
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }

  Future<String> getBackupData() async {
    final data = json.encode(_transactions.map((t) => t.toJson()).toList());
    return data;
  }

  Future<void> backupData() async {
    // Legacy method - kept for compatibility
    final data = await getBackupData();
    debugPrint('Backup data: $data');
  }

  Future<bool> restoreData(String backupData) async {
    try {
      final List<dynamic> decodedData = json.decode(backupData);
      _transactions =
          decodedData.map((item) => Transaction.fromJson(item)).toList();
      await _saveTransactions();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error restoring data: $e');
      return false;
    }
  }

  List<Transaction> getTransactionsByPeriod(String period) {
    if (_transactions.isEmpty) {
      return [];
    }

    final sorted = sortedTransactions;
    if (period == 'all') {
      return sorted;
    }

    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'weekly':
        final today = DateTime(now.year, now.month, now.day);
        final startOfCurrentWeek =
            today.subtract(Duration(days: today.weekday - 1));
        startDate = startOfCurrentWeek.subtract(const Duration(days: 6 * 7));
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month - 5, 1);
        break;
      case 'yearly':
      default:
        startDate = DateTime(now.year - 4, 1, 1);
        break;
    }

    return sorted.where((t) => !t.date.isBefore(startDate)).toList();
  }
}
