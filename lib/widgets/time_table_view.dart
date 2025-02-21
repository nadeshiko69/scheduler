import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../models/task.dart'; // Used via ScheduleItem.task

class TimeTableView extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<ScheduleItem> scheduleItems;
  final Function(TimeOfDay) onTimeSlotTap;
  final Function(Task, TimeOfDay) onTaskDrop;

  const TimeTableView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.scheduleItems,
    required this.onTimeSlotTap,
    required this.onTaskDrop,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = _calculateSlotCount() * 40.0; // 全体の高さを計算

    return SingleChildScrollView(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          children: [
            // 時間枠のグリッド
            Column(
              children: List.generate(_calculateSlotCount(), (index) {
                final currentTime = _indexToTime(index);
                return DragTarget<Task>(
                  onAccept: (task) => onTaskDrop(task, currentTime),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        color: candidateData.isNotEmpty
                            ? Colors.blue.withOpacity(0.1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          // 時間表示
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    color: Colors.grey.withOpacity(0.3)),
                              ),
                            ),
                            child: Text(
                              _formatTime(currentTime),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            // スケジュールブロック
            Positioned(
              left: 60, // 時間表示部分の幅
              right: 0,
              top: 0,
              bottom: 0,
              child: Stack(
                children: scheduleItems.map((item) {
                  final top = _calculateTopPosition(item.startTime);
                  final height = _calculateHeight(item.startTime, item.endTime);

                  return Positioned(
                    top: top,
                    left: 4,
                    right: 4,
                    height: height,
                    child: Container(
                      decoration: BoxDecoration(
                        color: item.task.color.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.task.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_formatTime(item.startTime)} - ${_formatTime(item.endTime)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTopPosition(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final currentMinutes = time.hour * 60 + time.minute;
    return ((currentMinutes - startMinutes) / 30) * 40;
  }

  double _calculateHeight(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return ((endMinutes - startMinutes) / 30) * 40;
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
}
