class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'credit' or 'debit'
  final DateTime date;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "type": type,
      "date": date.millisecondsSinceEpoch ~/ 1000,
      "category": category,
    };
  }
}
