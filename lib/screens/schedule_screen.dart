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
  // 設定から取得する想定
  TimeOfDay startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);

  // テスト用のタスクデータを追加
  List<Task> tasks = [
    Task(
      id: '1',
      title: '仕事',
      color: Colors.blue,
      targetDuration: const Duration(hours: 1),
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
      targetDuration: const Duration(minutes: 30),
    ),
  ];

  // テスト用のスケジュールデータを追加
  List<ScheduleItem> scheduleItems = [
    ScheduleItem(
      id: '1',
      task: Task(
        id: '1',
        title: '仕事',
        color: Colors.blue,
        targetDuration: const Duration(hours: 1),
      ),
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
    ),
    ScheduleItem(
      id: '2',
      task: Task(
        id: '2',
        title: '勉強',
        color: Colors.green,
        targetDuration: const Duration(hours: 2),
      ),
      startTime: TimeOfDay(hour: 14, minute: 0),
      endTime: TimeOfDay(hour: 16, minute: 0),
    ),
  ];

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
      body: Column(
        children: [
          TaskPalette(
            tasks: tasks,
            scheduleItems: scheduleItems,
            onTaskAdd: (task) {
              // タスク追加ロジック
            },
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TimeTableView(
                    startTime: startTime,
                    endTime: endTime,
                    scheduleItems: scheduleItems,
                    onTimeSlotTap: _handleTimeSlotTap,
                    onTaskDrop: _handleTaskDrop,
                  ),
                ),
                // タスク一覧
                Expanded(
                  flex: 1,
                  child: TaskListView(
                    tasks: tasks,
                    onTaskTap: _handleTaskTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleTimeSlotTap(TimeOfDay time) {
    // TODO: 選択された時間枠の処理
  }

  void _handleTaskTap(Task task) {
    // TODO: 選択されたタスクの処理
  }

  void _showAddTaskDialog() {
    // TODO: タスク追加ダイアログの表示
  }

  void _handleTaskDrop(Task task, TimeOfDay startTime) {
    // デフォルトで1時間の予定を追加
    final endTime = TimeOfDay(
      hour: startTime.hour + 1,
      minute: startTime.minute,
    );

    setState(() {
      scheduleItems.add(
        ScheduleItem(
          id: DateTime.now().toString(), // 一意のIDを生成
          task: task,
          startTime: startTime,
          endTime: endTime,
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
