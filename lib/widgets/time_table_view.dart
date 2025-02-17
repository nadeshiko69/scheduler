import 'package:flutter/material.dart';
import '../models/schedule_item.dart';

class TimeTableView extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<ScheduleItem> scheduleItems;
  final Function(TimeOfDay) onTimeSlotTap;

  const TimeTableView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.scheduleItems,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _calculateSlotCount(),
      itemBuilder: (context, index) {
        final currentTime = _indexToTime(index);
        final scheduleItem = _findScheduleItemForTime(currentTime);

        return GestureDetector(
          onTap: () => onTimeSlotTap(currentTime),
          child: Container(
            height: 40, // 高さを少し大きくして見やすく
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              color: scheduleItem?.task.color.withOpacity(0.3),
            ),
            child: Row(
              children: [
                // 時間表示
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    _formatTime(currentTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                // タスク表示
                if (scheduleItem != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        scheduleItem.task.title,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateSlotCount() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return ((endMinutes - startMinutes) / 30).ceil();
  }

  TimeOfDay _indexToTime(int index) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final currentMinutes = startMinutes + (index * 30);
    return TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  ScheduleItem? _findScheduleItemForTime(TimeOfDay time) {
    final timeInMinutes = time.hour * 60 + time.minute;

    try {
      return scheduleItems.firstWhere((item) {
        final startMinutes = item.startTime.hour * 60 + item.startTime.minute;
        final endMinutes = item.endTime.hour * 60 + item.endTime.minute;
        return timeInMinutes >= startMinutes && timeInMinutes < endMinutes;
      });
    } catch (e) {
      return null;
    }
  }
}
