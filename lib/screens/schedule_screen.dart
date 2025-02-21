import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule_item.dart';
import '../widgets/time_table_view.dart';
import '../widgets/task_list_view.dart';
import '../setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_palette.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TimeOfDay startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);

  // テスト用のタスクデータ
  List<Task> tasks = [
    Task(
      id: '1',
      title: '仕事',
      color: Colors.blue,
      targetDuration: const Duration(hours: 8),
    ),
    Task(
      id: '2',
      title: '勉強',
      color: Colors.green,
      targetDuration: const Duration(hours: 2),
    ),
    Task(
      id: '3',
      title: '運動',
      color: Colors.orange,
      targetDuration: const Duration(hours: 1),
    ),
  ];

  // テスト用のスケジュールデータ
  List<ScheduleItem> scheduleItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              // 設定画面から戻ってきたら設定を再読み込み
              await _loadSettings();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // タイムテーブル
            Expanded(
              flex: 4,
              child: TimeTableView(
                startTime: startTime,
                endTime: endTime,
                scheduleItems: scheduleItems,
                onTimeSlotTap: _handleTimeSlotTap,
                onTaskDrop: _handleTaskDrop,
              ),
            ),
            // 右側のタスクパレット
            Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: TaskPalette(
                      tasks: tasks,
                      scheduleItems: scheduleItems,
                      onTaskAdd: (task) {
                        // タスク追加ロジック
                      },
                    ),
                  ),
                  SizedBox(height: 80), // FloatingActionButtonのスペース
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleTimeSlotTap(TimeOfDay time) {
    // 時間枠タップ時の処理
    print('Tapped time: ${time.hour}:${time.minute}');
  }

  void _handleTaskTap(Task task) {
    // TODO: 選択されたタスクの処理
  }

  void _showAddTaskDialog() {
    // タスク追加ダイアログの処理
    print('Add task button pressed');
  }

  void _handleTaskDrop(Task task, TimeOfDay startTime) {
    setState(() {
      scheduleItems.add(
        ScheduleItem(
          id: DateTime.now().toString(),
          task: task,
          startTime: startTime,
          endTime: TimeOfDay(
            hour: startTime.hour + 1,
            minute: startTime.minute,
          ),
        ),
      );
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      startTime = TimeOfDay(
        hour: prefs.getInt('startHour') ?? 6,
        minute: prefs.getInt('startMinute') ?? 0,
      );
      endTime = TimeOfDay(
        hour: prefs.getInt('endHour') ?? 22,
        minute: prefs.getInt('endMinute') ?? 0,
      );
    });
  }
}
