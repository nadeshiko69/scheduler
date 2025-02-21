import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final Color color;
  final Duration targetDuration;

  Task({
    required this.id,
    required this.title,
    required this.color,
    required this.targetDuration,
  });
}
