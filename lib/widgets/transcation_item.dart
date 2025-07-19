
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transcation_model.dart';
import '../utils/format_currency.dart';
import '../utils/format_date.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.toLowerCase() == 'credit';
    final formattedDate = formatDate(transaction.date);
    final amountColor = isCredit ? Colors.green : Colors.red;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: amountColor.withOpacity(0.1),
        child: Icon(
          isCredit ? Icons.arrow_upward : Icons.arrow_downward,
          color: amountColor,
        ),
      ),
      title: Text(transaction.title,
          style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text("${transaction.category} • $formattedDate"),
      trailing: Text(
        "${isCredit ? '+' : '-'}${formatCurrency(transaction.amount)}",
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
