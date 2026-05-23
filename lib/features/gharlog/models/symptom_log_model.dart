class SymptomLogModel {
  final String id;
  final String memberId;
  final String date;
  final double? temperature;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? bloodSugar;
  final double? weight;
  final String? notes;

  SymptomLogModel({
    required this.id,
    required this.memberId,
    required this.date,
    this.temperature,
    this.bpSystolic,
    this.bpDiastolic,
    this.bloodSugar,
    this.weight,
    this.notes,
  });

  factory SymptomLogModel.fromJson(Map<String, dynamic> json) {
    return SymptomLogModel(
      id: json['_id'] ?? '',
      memberId: json['memberId'] ?? '',
      date: json['date'] ?? '',
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      bpSystolic: json['bpSystolic'],
      bpDiastolic: json['bpDiastolic'],
      bloodSugar: json['bloodSugar'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'date': date,
      'temperature': temperature,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'notes': notes,
    };
  }
}
