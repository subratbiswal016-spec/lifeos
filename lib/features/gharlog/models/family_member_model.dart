class FamilyMemberModel {
  final String id;
  final String name;
  final String relation;
  final int? age;
  final String? bloodGroup;
  final List<String>? allergies;
  final String? doctorName;
  final String? doctorPhone;
  final String? photoUrl;

  FamilyMemberModel({
    required this.id,
    required this.name,
    required this.relation,
    this.age,
    this.bloodGroup,
    this.allergies,
    this.doctorName,
    this.doctorPhone,
    this.photoUrl,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : null,
      doctorName: json['doctorName'],
      doctorPhone: json['doctorPhone'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'age': age,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'doctorName': doctorName,
      'doctorPhone': doctorPhone,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
