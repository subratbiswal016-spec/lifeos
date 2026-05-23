class MedicineLogModel {
  final String id;
  final String medicineId; // Could also expand to a full Medicine object if populated, but keep it simple
  final String memberId;
  final String date;
  final String? scheduledTime;
  final String status;
  final DateTime? takenAt;

  MedicineLogModel({
    required this.id,
    required this.medicineId,
    required this.memberId,
    required this.date,
    this.scheduledTime,
    this.status = 'pending',
    this.takenAt,
  });

  factory MedicineLogModel.fromJson(Map<String, dynamic> json) {
    return MedicineLogModel(
      id: json['_id'] ?? '',
      medicineId: json['medicineId'] ?? '',
      memberId: json['memberId'] ?? '',
      date: json['date'] ?? '',
      scheduledTime: json['scheduledTime'],
      status: json['status'] ?? 'pending',
      takenAt: json['takenAt'] != null ? DateTime.parse(json['takenAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'memberId': memberId,
      'date': date,
      'scheduledTime': scheduledTime,
      'status': status,
    };
  }
}
