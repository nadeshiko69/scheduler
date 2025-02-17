import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule_item.dart';
import '../widgets/time_table_view.dart';
import '../widgets/task_list_view.dart';
import '../setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    ),
    Task(
      id: '2',
      title: '勉強',
      color: Colors.green,
    ),
    Task(
      id: '3',
      title: '運動',
      color: Colors.orange,
    ),
  ];

  // テスト用のスケジュールデータを追加
  List<ScheduleItem> scheduleItems = [
    ScheduleItem(
      id: '1',
      task: Task(id: '1', title: '仕事', color: Colors.blue),
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
    ),
    ScheduleItem(
      id: '2',
      task: Task(id: '2', title: '勉強', color: Colors.green),
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
      body: Row(
        children: [
          // タイムテーブル
          Expanded(
            flex: 3,
            child: TimeTableView(
              startTime: startTime,
              endTime: endTime,
              scheduleItems: scheduleItems,
              onTimeSlotTap: _handleTimeSlotTap,
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
