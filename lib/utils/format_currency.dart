import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  return format.format(amount);
}