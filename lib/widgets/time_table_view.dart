// 時間テーブルビュー
// 時間枠のグリッドを表示できる
// スケジュールブロックを表示できる
// 時間枠をタップすると、時間枠の詳細画面に遷移する
// スケジュールブロックをドラッグアンドドロップでスケジュールに追加できる

import 'package:flutter/material.dart';
import '../models/schedule_item.dart';
import '../models/task.dart';
import './extended_time_picker.dart';
import 'dart:async';

class TimeTableView extends StatefulWidget {
  final ExtendedTimeOfDay startTime;
  final ExtendedTimeOfDay endTime;
  final List<ScheduleItem> scheduleItems;
  final Function(ExtendedTimeOfDay) onTimeSlotTap;
  final Function(Task, ExtendedTimeOfDay) onTaskDrop;
  final Function(ScheduleItem, ExtendedTimeOfDay) onScheduleResize;
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
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double? _currentTimePosition;

  @override
  void initState() {
    super.initState();
    // 初期化とスクロールを1つのpostFrameCallbackにまとめる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentTimePosition();
    });
    // 1分ごとに更新
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCurrentTimePosition();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateCurrentTimePosition() {
    final now = TimeOfDay.now();
    setState(() {
      _currentTimePosition =
          _calculateTopPosition(ExtendedTimeOfDay.fromTimeOfDay(now));
    });
    if (mounted) {
      _scrollToCurrentTime();
    }
  }

  void _scrollToCurrentTime() {
    if (_currentTimePosition != null && mounted) {
      final screenHeight = MediaQuery.of(context).size.height;
      _scrollController.animateTo(
        _currentTimePosition! - (screenHeight / 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = _calculateSlotCount() * 40.0;

    return SingleChildScrollView(
      controller: _scrollController,
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
                      _onTaskDrop(details.data, currentTime),
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
                children: widget.scheduleItems.map((item) {
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
                            _onScheduleResize(item, newEndTime),
                        onDelete: () => _onScheduleDelete(item),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // 現在時刻のマーカー
            if (_currentTimePosition != null)
              Positioned(
                left: 0,
                right: 0,
                top: _currentTimePosition,
                child: Container(
                  height: 2,
                  color: Colors.red,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateTopPosition(ExtendedTimeOfDay time) {
    final startMinutes = widget.startTime.hour * 60 + widget.startTime.minute;
    final currentMinutes = time.hour * 60 + time.minute;
    return ((currentMinutes - startMinutes) / 30) * 40;
  }

  double _calculateHeight(ExtendedTimeOfDay start, ExtendedTimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return ((endMinutes - startMinutes) / 30) * 40;
  }

  int _calculateSlotCount() {
    final startMinutes = widget.startTime.hour * 60 + widget.startTime.minute;
    final endMinutes = widget.endTime.hour * 60 + widget.endTime.minute;
    return ((endMinutes - startMinutes) / 30).ceil();
  }

  ExtendedTimeOfDay _indexToTime(int index) {
    final startMinutes = widget.startTime.hour * 60 + widget.startTime.minute;
    final currentMinutes = startMinutes + (index * 30);
    return ExtendedTimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );
  }

  String _formatTime(ExtendedTimeOfDay time) {
    final hour = time.hour >= 24 ? time.hour - 24 : time.hour;
    final suffix = time.hour >= 24 ? '(翌)' : '';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}$suffix';
  }

  void _onTaskDrop(Task task, ExtendedTimeOfDay time) {
    widget.onTaskDrop(task, time);
  }

  void _onScheduleResize(ScheduleItem item, ExtendedTimeOfDay newEndTime) {
    widget.onScheduleResize(item, newEndTime);
  }

  void _onScheduleDelete(ScheduleItem item) {
    widget.onScheduleDelete(item);
  }
}

class _ResizableScheduleItem extends StatefulWidget {
  final ScheduleItem scheduleItem;
  final Function(ExtendedTimeOfDay) onResize;
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
  ExtendedTimeOfDay? _originalEndTime;
  static const double timeSlotHeight = 40.0; // 30分の高さ
  static const int minutesPerSlot = 30;
  static const int resizeStep = 15; // 15分単位に変更

  ExtendedTimeOfDay _snapToNearestStep(ExtendedTimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute;
    final snappedMinutes = (totalMinutes / resizeStep).round() * resizeStep;
    return ExtendedTimeOfDay(
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
                final snappedTime = _snapToNearestStep(ExtendedTimeOfDay(
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

  String _formatTime(ExtendedTimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
