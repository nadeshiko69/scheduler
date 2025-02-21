import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule_item.dart';

class TaskPalette extends StatelessWidget {
  final List<Task> tasks;
  final List<ScheduleItem> scheduleItems;
  final Function(Task) onTaskAdd;

  const TaskPalette({
    super.key,
    required this.tasks,
    required this.scheduleItems,
    required this.onTaskAdd,
  });

  Duration _calculateTaskDuration(Task task) {
    final taskSchedules =
        scheduleItems.where((item) => item.task.id == task.id);
    return taskSchedules.fold(
      Duration.zero,
      (total, item) {
        final startMinutes = item.startTime.hour * 60 + item.startTime.minute;
        final endMinutes = item.endTime.hour * 60 + item.endTime.minute;
        return total + Duration(minutes: endMinutes - startMinutes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final usedDuration = _calculateTaskDuration(task);

          return Draggable<Task>(
            data: task,
            feedback: _buildTaskCard(task, usedDuration, true),
            childWhenDragging:
                _buildTaskCard(task, usedDuration, false, opacity: 0.5),
            child: _buildTaskCard(task, usedDuration, false),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task, Duration usedDuration, bool isDragging,
      {double opacity = 1.0}) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: task.color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${usedDuration.inHours}h ${usedDuration.inMinutes % 60}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          Text(
            '/ ${task.targetDuration.inHours}h',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
