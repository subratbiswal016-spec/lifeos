class MedicineModel {
  final String id;
  final String memberId;
  final String name;
  final String? dose;
  final int? timesPerDay;
  final List<String>? reminderTimes;
  final int? durationDays;
  final int? remainingQuantity;
  final bool? isActive;
  final List<String>? takenTimes;

  MedicineModel({
    required this.id,
    required this.memberId,
    required this.name,
    this.dose,
    this.timesPerDay,
    this.reminderTimes,
    this.durationDays,
    this.remainingQuantity,
    this.isActive,
    this.takenTimes,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['_id'] ?? '',
      memberId: json['memberId'] ?? '',
      name: json['name'] ?? '',
      dose: json['dose'],
      timesPerDay: json['timesPerDay'],
      durationDays: json['durationDays'],
      remainingQuantity: json['remainingQuantity'],
      reminderTimes: json['reminderTimes'] != null ? List<String>.from(json['reminderTimes']) : null,
      isActive: json['isActive'],
      takenTimes: json['takenTimes'] != null ? List<String>.from(json['takenTimes']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'name': name,
      'dose': dose,
      'timesPerDay': timesPerDay,
      'durationDays': durationDays,
      'reminderTimes': reminderTimes,
    };
  }
}
