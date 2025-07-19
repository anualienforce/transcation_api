// lib/providers/transaction_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';

import '../api/transcation_api.dart';
import '../models/transcation_model.dart';

enum ScreenState { loading, success, empty, error }

class TransactionProvider with ChangeNotifier {

  List<TransactionModel> _allTransactions = []; // Holds ALL transactions from the API
  ScreenState _baseScreenState = ScreenState.loading;
  String _errorMessage = '';


  String? _selectedTypeFilter; // null means 'All'
  String? _selectedCategoryFilter; // null means 'All'



  String? get selectedTypeFilter => _selectedTypeFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  String get errorMessage => _errorMessage;

  ScreenState get screenState {
    if (_baseScreenState != ScreenState.success) {
      return _baseScreenState; // Return loading or error states immediately
    }
    return transactions.isEmpty ? ScreenState.empty : ScreenState.success;
  }

  List<TransactionModel> get transactions {
    return _allTransactions.where((transaction) {
      final typeMatch = _selectedTypeFilter == null || transaction.type == _selectedTypeFilter;
      final categoryMatch = _selectedCategoryFilter == null || transaction.category == _selectedCategoryFilter;
      return typeMatch && categoryMatch;
    }).toList();
  }

  Set<String> get availableCategories {
    return _allTransactions.map((t) => t.category).toSet();
  }

  double get totalCredit {
    return transactions // Use the filtered list
        .where((t) => t.type == 'credit')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalDebit {
    return transactions // Use the filtered list
        .where((t) => t.type == 'debit')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalBalance {
    return totalCredit - totalDebit;
  }

  TransactionProvider() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _baseScreenState = ScreenState.loading;
    _selectedTypeFilter = null;
    _selectedCategoryFilter = null;
    notifyListeners();

    try {
      final fetchedTransactions = await TransactionAPI.fetchTransactions();
      fetchedTransactions.sort((a, b) => b.date.compareTo(a.date));

      _allTransactions = fetchedTransactions;
      _baseScreenState = _allTransactions.isEmpty ? ScreenState.empty : ScreenState.success;
    } on SocketException {
      _errorMessage = "No Internet Connection. Please try again.";
      _baseScreenState = ScreenState.error;
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _baseScreenState = ScreenState.error;
    }
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final addedTransaction = await TransactionAPI.addTransaction(transaction);
      _allTransactions.insert(0, addedTransaction);
      _baseScreenState = ScreenState.success;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  
  void updateTypeFilter(String? type) {
    _selectedTypeFilter = type;
    notifyListeners(); // Notify UI to rebuild with the new filter
  }

  void updateCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners(); // Notify UI to rebuild with the new filter
  }
}