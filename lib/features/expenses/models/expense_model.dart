class Expense {
  final String id;
  final String category;
  final double amount;
  final String type;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'expense',
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}
