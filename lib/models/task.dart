// タスク
// タスク名、色、目標時間を持つ
// タスクは、スケジュールアイテムのリストとして管理される

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
