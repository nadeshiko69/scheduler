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
}
