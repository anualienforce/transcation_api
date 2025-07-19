// lib/providers/transaction_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';

import '../api/transcation_api.dart';
import '../models/transcation_model.dart';

enum ScreenState { loading, success, empty, error }

class TransactionProvider with ChangeNotifier {
  // --- Private State Variables ---
  List<TransactionModel> _allTransactions = []; // Holds ALL transactions from the API
  ScreenState _baseScreenState = ScreenState.loading;
  String _errorMessage = '';

  // --- NEW: Filter State Variables ---
  String? _selectedTypeFilter; // null means 'All'
  String? _selectedCategoryFilter; // null means 'All'


  // --- Public Getters for UI to read state ---

  // NEW: Expose the current filter values so the UI can highlight the active filter
  String? get selectedTypeFilter => _selectedTypeFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  String get errorMessage => _errorMessage;

  // NEW: A smart getter for screen state. It returns 'empty' if filters result in no items.
  ScreenState get screenState {
    if (_baseScreenState != ScreenState.success) {
      return _baseScreenState; // Return loading or error states immediately
    }
    // If base state is success, check if the *filtered* list is empty
    return transactions.isEmpty ? ScreenState.empty : ScreenState.success;
  }

  // --- Main Getter for the UI to display transactions ---
  // This getter dynamically applies the filters to the master list.
  List<TransactionModel> get transactions {
    return _allTransactions.where((transaction) {
      final typeMatch = _selectedTypeFilter == null || transaction.type == _selectedTypeFilter;
      final categoryMatch = _selectedCategoryFilter == null || transaction.category == _selectedCategoryFilter;
      return typeMatch && categoryMatch;
    }).toList();
  }

  // NEW: A getter to provide a unique list of all available categories for the filter UI
  Set<String> get availableCategories {
    return _allTransactions.map((t) => t.category).toSet();
  }

  // --- Getters for Calculated Values (now work on the filtered list) ---
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

  // --- Business Logic Methods ---

  TransactionProvider() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _baseScreenState = ScreenState.loading;
    // Clear filters on refresh
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

  // --- NEW: Methods to update filters ---
  void updateTypeFilter(String? type) {
    _selectedTypeFilter = type;
    notifyListeners(); // Notify UI to rebuild with the new filter
  }

  void updateCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners(); // Notify UI to rebuild with the new filter
  }
}