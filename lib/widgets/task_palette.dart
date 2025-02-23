// タスクパレット
// タスクを表示できる
// タスクをドラッグアンドドロップでスケジュールに追加できる
// タスクを削除できる

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule_item.dart';

class TaskPalette extends StatelessWidget {
  final List<Task> tasks;
  final List<ScheduleItem> scheduleItems;
  final Function(Task) onTaskAdd;
  final Function(Task) onTaskDelete;

  const TaskPalette({
    super.key,
    required this.tasks,
    required this.scheduleItems,
    required this.onTaskAdd,
    required this.onTaskDelete,
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
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final usedDuration = _calculateTaskDuration(task);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Draggable<Task>(
              data: task,
              feedback: _buildTaskCard(task, usedDuration, true),
              childWhenDragging:
                  _buildTaskCard(task, usedDuration, false, opacity: 0.5),
              child: _buildTaskCard(task, usedDuration, false),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task, Duration usedDuration, bool isDragging,
      {double opacity = 1.0}) {
    return Card(
      color: task.color.withOpacity(opacity),
      elevation: isDragging ? 8 : 2,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Column(
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
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => onTaskDelete(task),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
