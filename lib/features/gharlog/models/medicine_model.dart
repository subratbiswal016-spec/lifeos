class MedicineModel {
  final String id;
  final String memberId;
  final String name;
  final String? dose;
  final int? timesPerDay;
  final List<String>? reminderTimes;
  final bool isActive;

  MedicineModel({
    required this.id,
    required this.memberId,
    required this.name,
    this.dose,
    this.timesPerDay,
    this.reminderTimes,
    this.isActive = true,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['_id'] ?? '',
      memberId: json['memberId'] ?? '',
      name: json['name'] ?? '',
      dose: json['dose'],
      timesPerDay: json['timesPerDay'],
      reminderTimes: json['reminderTimes'] != null ? List<String>.from(json['reminderTimes']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'name': name,
      'dose': dose,
      'timesPerDay': timesPerDay,
      'reminderTimes': reminderTimes,
    };
  }
}
