class UdharModel {
  final String id;
  final String personName;
  final int amount;
  final String type; // 'gave' or 'took'
  final String? description;
  final DateTime date;
  final bool isSettled;

  UdharModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.isSettled = false,
  });

  factory UdharModel.fromJson(Map<String, dynamic> json) {
    return UdharModel(
      id: json['_id'] as String,
      personName: json['personName'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      isSettled: json['isSettled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personName': personName,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'isSettled': isSettled,
    };
  }
}
