class SubjectModel {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String color;
  final int weeklyTargetHours;
  final int dailyTargetHours;
  final bool isActive;

  SubjectModel({
    required this.id,
    required this.userId,
    required this.name,
    this.emoji = '📚',
    this.color = '#6C63FF',
    this.weeklyTargetHours = 0,
    this.dailyTargetHours = 0,
    this.isActive = true,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📚',
      color: json['color'] ?? '#6C63FF',
      weeklyTargetHours: json['weeklyTargetHours'] ?? 0,
      dailyTargetHours: json['dailyTargetHours'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'color': color,
      'weeklyTargetHours': weeklyTargetHours,
      'dailyTargetHours': dailyTargetHours,
      'isActive': isActive,
    };
  }
}
