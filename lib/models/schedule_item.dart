// スケジュールアイテム
// タスク、開始時間、終了時間を持つ
// スケジュールアイテムは、タスクのリストとして管理される

import 'package:flutter/material.dart';
import 'task.dart';

class ScheduleItem {
  final String id;
  final Task task;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  ScheduleItem({
    required this.id,
    required this.task,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task.toJson(),
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      task: Task.fromJson(json['task']),
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'],
        minute: json['endTime']['minute'],
      ),
    );
  }
}
