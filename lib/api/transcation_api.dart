import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/transcation_model.dart';


class TransactionAPI {
  static const baseUrl = 'https://687b36a4b4bc7cfbda84fe9b.mockapi.io/transcation';

  static Future<List<TransactionModel>> fetchTransactions() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List decoded = jsonDecode(res.body);
      return decoded.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<TransactionModel> addTransaction(TransactionModel data) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );
    if (res.statusCode == 201) {
      return TransactionModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to add transaction');
    }
  }
}
