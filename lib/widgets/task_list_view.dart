import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(); // TODO: Implement task list view
  }
}
