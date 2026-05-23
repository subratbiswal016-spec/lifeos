class HabitModel {
  final String id;
  final String name;
  final String? emoji;
  final String? color;
  final String frequency;
  final List<int>? customDays;
  final bool isActive;
  final bool isCompletedToday;

  HabitModel({
    required this.id,
    required this.name,
    this.emoji,
    this.color,
    required this.frequency,
    this.customDays,
    this.isActive = true,
    this.isCompletedToday = false,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'],
      color: json['color'],
      frequency: json['frequency'] ?? 'daily',
      customDays: json['customDays'] != null ? List<int>.from(json['customDays']) : null,
      isActive: json['isActive'] ?? true,
      isCompletedToday: json['isCompletedToday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'color': color,
      'frequency': frequency,
      'customDays': customDays,
    };
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? emoji,
    String? color,
    String? frequency,
    List<int>? customDays,
    bool? isActive,
    bool? isCompletedToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      isActive: isActive ?? this.isActive,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }
}
