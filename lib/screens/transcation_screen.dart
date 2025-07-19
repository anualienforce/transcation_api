// lib/screens/transcation_screen.dart

import 'package:api_transcation/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transcation_model.dart';
import '../provider/transcation_provider.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error.dart';
import '../widgets/loader.dart';
import '../widgets/transcation_item.dart';

class TranscationScreen extends StatelessWidget {
  const TranscationScreen({super.key});

  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedType = 'credit';
    DateTime selectedDate = DateTime.now();
    bool isAdding = false;
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext dialogContext) {
      return StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Add New Transaction'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (value) => value!.isEmpty ? 'Please enter a title' : null),
                  TextFormField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (value) { if (value!.isEmpty) { return 'Please enter an amount'; } if (double.tryParse(value) == null) { return 'Please enter a valid number'; }if (double.tryParse(value)! <= 0) { return 'Please enter a positive number or amount cannot be 0'; } return null; }),
                  TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category'), validator: (value) => value!.isEmpty ? 'Please enter a category' : null),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(value: selectedType, decoration: const InputDecoration(labelText: 'Type'), items: ['credit', 'debit'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(), onChanged: (value) { setDialogState(() { selectedType = value!; }); }),
                  const SizedBox(height: 16),
                  Row(children: [ Expanded(child: Text('Date: ${DateFormat.yMd().format(selectedDate)}')), IconButton(icon: const Icon(Icons.calendar_today), onPressed: () async { final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now()); if (picked != null && picked != selectedDate) { setDialogState(() { selectedDate = picked; }); } })]),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: isAdding ? null : () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isAdding ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isAdding = true);
                  final newTransaction = TransactionModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    type: selectedType,
                    date: selectedDate,
                    category: categoryController.text,
                  );
                  try {
                    await transactionProvider.addTransaction(newTransaction);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Added!')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  } finally {
                    setDialogState(() => isAdding = false);
                  }
                }
              },
              child: isAdding ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)) : const Text('Add'),
            ),
          ],
        );
      });
    });
  }
  Widget _buildFilterControls(BuildContext context, TransactionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter by Type', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: provider.selectedTypeFilter == null,
                onSelected: (selected) => provider.updateTypeFilter(null),
              ),
              FilterChip(
                label: const Text('Credit'),
                selected: provider.selectedTypeFilter == 'credit',
                onSelected: (selected) => provider.updateTypeFilter('credit'),
                selectedColor: Colors.green.shade100,
              ),
              FilterChip(
                label: const Text('Debit'),
                selected: provider.selectedTypeFilter == 'debit',
                onSelected: (selected) => provider.updateTypeFilter('debit'),
                selectedColor: Colors.red.shade100,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Filter by Category', style: TextStyle(fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: const Text('All Categories'),
                    selected: provider.selectedCategoryFilter == null,
                    onSelected: (selected) => provider.updateCategoryFilter(null),
                  ),
                ),

                ...provider.availableCategories.map((category) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: provider.selectedCategoryFilter == category,
                    onSelected: (selected) => provider.updateCategoryFilter(category),
                  ),
                )),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          switch (provider.screenState) {
            case ScreenState.loading:
              return const Loader();
            case ScreenState.error:
              return ErrorApi(message: provider.errorMessage, onRetry: provider.fetchTransactions);
            case ScreenState.empty:
              return Column(
                children: [
                  _buildFilterControls(context, provider),
                  const Expanded(child: EmptyWidget(message: 'No transactions match your filters.')),
                ],
              );
            case ScreenState.success:
              return RefreshIndicator(
                onRefresh: provider.fetchTransactions,
                child: Column( // Used a Column to stack filters and the list
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Filtered Balance: ${formatCurrency(provider.totalBalance)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Credit: ${formatCurrency(provider.totalCredit)}', style: TextStyle(color: Colors.green, fontSize: 16)),
                              Text('Debit: ${formatCurrency(provider.totalDebit)}', style: TextStyle(color: Colors.red, fontSize: 16)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(height: 1),


                    _buildFilterControls(context, provider),
                    const Divider(height: 1),

                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          final transaction = provider.transactions[index];
                          return TransactionItem(transaction: transaction);
                        },
                        itemCount: provider.transactions.length,
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
      floatingActionButton: Consumer<TransactionProvider>( /* No changes here */
        builder: (context, provider, child) {
          final isEnabled = provider.screenState == ScreenState.success || provider.screenState == ScreenState.empty;
          return FloatingActionButton(
            onPressed: isEnabled ? () => _showAddTransactionDialog(context) : null,
            backgroundColor: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}