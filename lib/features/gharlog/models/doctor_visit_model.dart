import 'family_member_model.dart';

class DoctorVisitModel {
  final String id;
  final String memberId;
  final String date;
  final String doctorName;
  final String? hospital;
  final String? reason;
  final String? notes;
  final String? prescriptionImageUrl;
  final String? nextAppointment;
  final FamilyMemberModel? member; // Populated from backend

  DoctorVisitModel({
    required this.id,
    required this.memberId,
    required this.date,
    required this.doctorName,
    this.hospital,
    this.reason,
    this.notes,
    this.prescriptionImageUrl,
    this.nextAppointment,
    this.member,
  });

  factory DoctorVisitModel.fromJson(Map<String, dynamic> json) {
    FamilyMemberModel? mem;
    if (json['memberId'] is Map<String, dynamic>) {
      mem = FamilyMemberModel.fromJson(json['memberId']);
    }
    
    return DoctorVisitModel(
      id: json['_id'] ?? '',
      memberId: mem != null ? mem.id : (json['memberId'] ?? ''),
      date: json['date'] ?? '',
      doctorName: json['doctorName'] ?? '',
      hospital: json['hospital'],
      reason: json['reason'],
      notes: json['notes'],
      prescriptionImageUrl: json['prescriptionImageUrl'],
      nextAppointment: json['nextAppointment'],
      member: mem,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'date': date,
      'doctorName': doctorName,
      'hospital': hospital,
      'reason': reason,
      'notes': notes,
      'prescriptionImageUrl': prescriptionImageUrl,
      'nextAppointment': nextAppointment,
    };
  }
}
