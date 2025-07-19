// lib/providers/transaction_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';

import '../api/transcation_api.dart';
import '../models/transcation_model.dart';


// The same enum we used before, now part of the provider's logic
enum ScreenState { loading, success, empty, error }

class TransactionProvider with ChangeNotifier {
  // --- Private State Variables ---
  List<TransactionModel> _transactions = [];
  ScreenState _screenState = ScreenState.loading;
  String _errorMessage = '';

  // --- Public Getters to Access State ---
  // This prevents the UI from directly modifying the state list
  List<TransactionModel> get transactions => _transactions;
  ScreenState get screenState => _screenState;
  String get errorMessage => _errorMessage;

  // --- Getters for Calculated Values ---
  // It's better to calculate these on the fly to ensure they are always up to date.
  double get totalCredit {
    return _transactions
        .where((t) => t.type == 'credit')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalDebit {
    return _transactions
        .where((t) => t.type == 'debit')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalBalance {
    return totalCredit - totalDebit;
  }

  // --- Business Logic Methods ---

  TransactionProvider() {
    // Fetch data immediately when the provider is created.
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _screenState = ScreenState.loading;
    notifyListeners(); // Notify UI to show loading indicator

    try {
      final List<TransactionModel> fetchedTransactions = await TransactionAPI.fetchTransactions();
      fetchedTransactions.sort((a, b) => b.date.compareTo(a.date));

      _transactions = fetchedTransactions;
      _screenState = _transactions.isEmpty ? ScreenState.empty : ScreenState.success;
    } on SocketException {
      _errorMessage = "No Internet Connection. Please try again.";
      _screenState = ScreenState.error;
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      _screenState = ScreenState.error;
    }
    // Notify the UI that the state has changed (either to success, empty, or error)
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final addedTransaction = await TransactionAPI.addTransaction(transaction);
      // Add the new item to the top of the list
      _transactions.insert(0, addedTransaction);
      // If the list was empty, the state is now 'success'
      _screenState = ScreenState.success;
      // Notify listeners to rebuild the UI with the new item
      notifyListeners();
    } catch (e) {
      // If adding fails, re-throw the error so the UI can catch it and show a SnackBar
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }
}