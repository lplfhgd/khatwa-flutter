import 'package:flutter/material.dart';

class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.label,
    required this.time,
    required this.iconName,
    this.enabled = true,
    this.isCompleted = false,
  });

  final String id;
  final String label;

  /// Stored as HH:mm.
  final String time;

  final String iconName;
  final bool enabled;
  final bool isCompleted;

  IconData get symbol {
    switch (iconName) {
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'clean':
        return Icons.clean_hands_outlined;
      case 'food':
        return Icons.breakfast_dining_outlined;
      case 'walk':
        return Icons.directions_walk_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'play':
        return Icons.sports_esports_outlined;
      default:
        return Icons.checklist_outlined;
    }
  }

  int get hour {
    final parts = time.split(':');
    return int.tryParse(parts.first) ?? 0;
  }

  int get minute {
    final parts = time.split(':');
    if (parts.length < 2) return 0;

    return int.tryParse(parts[1]) ?? 0;
  }

  factory RoutineModel.fromMap(Map<String, dynamic> map) {
    return RoutineModel(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? map['title']?.toString() ?? '',
      time: map['time']?.toString() ?? '07:00',
      iconName: map['iconName']?.toString() ?? 'task',
      enabled: map['enabled'] as bool? ?? true,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'time': time,
      'iconName': iconName,
      'enabled': enabled,
      'isCompleted': isCompleted,
    };
  }

  RoutineModel copyWith({
    String? id,
    String? label,
    String? time,
    String? iconName,
    bool? enabled,
    bool? isCompleted,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      label: label ?? this.label,
      time: time ?? this.time,
      iconName: iconName ?? this.iconName,
      enabled: enabled ?? this.enabled,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
