import 'package:flutter/material.dart';

class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.label,
    required this.symbol,
    this.isCompleted = false,
  });

  final String id;
  final String label;
  final IconData symbol;
  final bool isCompleted;

  RoutineModel copyWith({
    String? id,
    String? label,
    IconData? symbol,
    bool? isCompleted,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      label: label ?? this.label,
      symbol: symbol ?? this.symbol,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
