import 'package:flutter/material.dart';

class ExtendedTimeOfDay {
  final int hour;
  final int minute;

  const ExtendedTimeOfDay({
    required this.hour,
    required this.minute,
  });

  // 追加: JSONシリアライズ用のメソッド
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  // 追加: JSON逆シリアライズ用のファクトリメソッド
  factory ExtendedTimeOfDay.fromJson(Map<String, dynamic> json) {
    return ExtendedTimeOfDay(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  factory ExtendedTimeOfDay.fromTimeOfDay(TimeOfDay time) {
    return ExtendedTimeOfDay(hour: time.hour, minute: time.minute);
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour % 24, minute: minute);
  }

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class ExtendedTimePicker extends StatefulWidget {
  final ExtendedTimeOfDay initialTime;
  final ExtendedTimeOfDay? startTime; // 追加: 開始時刻

  const ExtendedTimePicker({
    super.key,
    required this.initialTime,
    this.startTime, // 追加
  });

  @override
  State<ExtendedTimePicker> createState() => _ExtendedTimePickerState();
}

class _ExtendedTimePickerState extends State<ExtendedTimePicker> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
  }

  // 時刻を調整するヘルパーメソッド
  int _adjustHour(int hour) {
    if (widget.startTime != null) {
      final startTotalMinutes =
          widget.startTime!.hour * 60 + widget.startTime!.minute;
      final selectedTotalMinutes = hour * 60 + selectedMinute;

      // 選択時刻が開始時刻より前の場合、24時間を加算
      if (selectedTotalMinutes < startTotalMinutes) {
        return hour + 24;
      }
    }
    return hour;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('時刻を選択'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 時の選択
              DropdownButton<int>(
                value: selectedHour % 24, // 表示用に24時間形式に変換
                items: List.generate(24, (index) => index).map((hour) {
                  return DropdownMenuItem(
                    value: hour,
                    child: Text(hour.toString().padLeft(2, '0')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedHour = _adjustHour(value);
                    });
                  }
                },
              ),
              const Text(' : '),
              // 分の選択
              DropdownButton<int>(
                value: selectedMinute,
                items: List.generate(4, (index) => index * 15).map((minute) {
                  return DropdownMenuItem(
                    value: minute,
                    child: Text(minute.toString().padLeft(2, '0')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMinute = value;
                      // 分を変更した際も時間の調整を行う
                      selectedHour = _adjustHour(selectedHour % 24);
                    });
                  }
                },
              ),
            ],
          ),
          if (selectedHour >= 24) ...[
            const SizedBox(height: 8),
            Text(
              '(翌日 ${selectedHour - 24}:${selectedMinute.toString().padLeft(2, '0')})',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              ExtendedTimeOfDay(
                hour: selectedHour,
                minute: selectedMinute,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
