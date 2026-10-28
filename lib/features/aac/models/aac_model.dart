import 'package:flutter/material.dart';

class AacModel {
  const AacModel({
    required this.id,
    required this.label,
    required this.symbol,
    required this.category,
  });

  final String id;
  final String label;
  final IconData symbol;
  final String category;
}
