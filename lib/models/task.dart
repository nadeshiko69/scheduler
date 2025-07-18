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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.value.toUnsigned(32).toString(),
      'targetDuration': targetDuration.inMinutes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      color: Color(int.parse(json['color'])),
      targetDuration: Duration(minutes: json['targetDuration']),
    );
  }
}
