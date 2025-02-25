// 時間テーブルビュー
// 時間枠のグリッドを表示できる
// スケジュールブロックを表示できる
// 時間枠をタップすると、時間枠の詳細画面に遷移する
// スケジュールブロックをドラッグアンドドロップでスケジュールに追加できる

import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../models/task.dart';

class TimeTableView extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<ScheduleItem> scheduleItems;
  final Function(TimeOfDay) onTimeSlotTap;
  final Function(Task, TimeOfDay) onTaskDrop;
  final Function(ScheduleItem, TimeOfDay) onScheduleResize;
  final Function(ScheduleItem) onScheduleDelete;

  const TimeTableView({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.scheduleItems,
    required this.onTimeSlotTap,
    required this.onTaskDrop,
    required this.onScheduleResize,
    required this.onScheduleDelete,
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
                  onAcceptWithDetails: (details) =>
                      onTaskDrop(details.data, currentTime),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.withAlpha(77)),
                        ),
                        color: candidateData.isNotEmpty
                            ? Colors.blue.withAlpha(26)
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
                                    color: Colors.grey.withAlpha(77)),
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
                    left: 0,
                    right: 0,
                    height: height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _ResizableScheduleItem(
                        scheduleItem: item,
                        onResize: (newEndTime) =>
                            onScheduleResize(item, newEndTime),
                        onDelete: () => onScheduleDelete(item),
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

class _ResizableScheduleItem extends StatefulWidget {
  final ScheduleItem scheduleItem;
  final Function(TimeOfDay) onResize;
  final VoidCallback onDelete;

  const _ResizableScheduleItem({
    required this.scheduleItem,
    required this.onResize,
    required this.onDelete,
  });

  @override
  State<_ResizableScheduleItem> createState() => _ResizableScheduleItemState();
}

class _ResizableScheduleItemState extends State<_ResizableScheduleItem> {
  double? _dragStartY;
  TimeOfDay? _originalEndTime;
  static const double timeSlotHeight = 40.0; // 30分の高さ
  static const int minutesPerSlot = 30;
  static const int resizeStep = 15; // 15分単位に変更

  TimeOfDay _snapToNearestStep(TimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute;
    final snappedMinutes = (totalMinutes / resizeStep).round() * resizeStep;
    return TimeOfDay(
      hour: snappedMinutes ~/ 60,
      minute: snappedMinutes % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // タスクブロック本体
        GestureDetector(
          onLongPress: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('スケジュールの削除'),
                content:
                    Text('「${widget.scheduleItem.task.title}」をスケジュールから削除しますか？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('削除'),
                  ),
                ],
              ),
            );
            if (shouldDelete == true) {
              widget.onDelete();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.scheduleItem.task.color.withAlpha(204),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
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
                    widget.scheduleItem.task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_formatTime(widget.scheduleItem.startTime)} - ${_formatTime(widget.scheduleItem.endTime)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // リサイズハンドル
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _dragStartY = details.localPosition.dy;
              _originalEndTime = widget.scheduleItem.endTime;
            },
            onVerticalDragUpdate: (details) {
              if (_dragStartY != null && _originalEndTime != null) {
                final deltaY = details.localPosition.dy - _dragStartY!;
                // 15分単位に調整（20pxが15分に相当）
                final deltaMinutes =
                    (deltaY / timeSlotHeight * minutesPerSlot).round() *
                        (resizeStep / minutesPerSlot);

                final originalMinutes =
                    _originalEndTime!.hour * 60 + _originalEndTime!.minute;
                final newMinutes = originalMinutes + deltaMinutes.floor();

                // 15分単位にスナップ
                final snappedTime = _snapToNearestStep(TimeOfDay(
                  hour: newMinutes ~/ 60,
                  minute: newMinutes % 60,
                ));

                // 開始時刻より後になるようにチェック
                final startMinutes = widget.scheduleItem.startTime.hour * 60 +
                    widget.scheduleItem.startTime.minute;
                if (snappedTime.hour * 60 + snappedTime.minute > startMinutes) {
                  widget.onResize(snappedTime);
                }
              }
            },
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(26),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(128), // 0.5 * 255 ≈ 128
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
