// スケジュール画面
// タスクを追加、削除、編集できる
// タスクをスケジュールに追加できる
// スケジュールを表示できる
// スケジュールを編集できる
// スケジュールを削除できる

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule_item.dart';
import '../widgets/time_table_view.dart';
import '../widgets/task_list_view.dart';
import '../setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/task_palette.dart';
import '../widgets/add_task_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadRewardedAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1142801310983686/7314491612', // 実際の広告ユニットIDに変更
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1142801310983686/4361025214', // リワード広告の正しいユニットID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          print('Rewarded ad loaded'); // デバッグ用
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          print('Rewarded ad failed to load: $error'); // デバッグ用
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetConfirmation,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              await _loadSettings();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                      onScheduleResize: _handleScheduleResize,
                      onScheduleDelete: _handleScheduleDelete,
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
                            onTaskAdd: (task) {},
                            onTaskDelete: _handleTaskDelete,
                          ),
                        ),
                        SizedBox(height: 80), // FloatingActionButtonのスペース
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 広告を表示
            if (_isAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
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

  void _showAddTaskDialog() async {
    final newTask = await showDialog<Task>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
    }
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

  void _handleTaskDelete(Task task) async {
    // 確認ダイアログを表示
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タスクの削除'),
        content: Text('「${task.title}」を削除しますか？\n関連するスケジュールもすべて削除されます。'),
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

    // ユーザーが削除を確認した場合のみ削除を実行
    if (shouldDelete == true) {
      setState(() {
        tasks.removeWhere((t) => t.id == task.id);
        scheduleItems.removeWhere((item) => item.task.id == task.id);
      });
    }
  }

  void _handleScheduleResize(ScheduleItem item, TimeOfDay newEndTime) {
    setState(() {
      final index = scheduleItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        scheduleItems[index] = ScheduleItem(
          id: item.id,
          task: item.task,
          startTime: item.startTime,
          endTime: newEndTime,
        );
      }
    });
  }

  void _handleScheduleDelete(ScheduleItem item) {
    setState(() {
      scheduleItems.removeWhere((i) => i.id == item.id);
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

  void _showResetConfirmation() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールのリセット'),
        content: const Text('配置中のタスクをすべて削除しますか？'),
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

    if (shouldReset == true) {
      if (_isRewardedAdReady && _rewardedAd != null) {
        try {
          _rewardedAd?.show(
            onUserEarnedReward: (_, reward) {
              print('User earned reward: ${reward.amount}'); // デバッグ用
              setState(() {
                scheduleItems.clear();
              });
            },
          );
          _rewardedAd = null;
          _isRewardedAdReady = false;
          _loadRewardedAd(); // 次回のために新しい広告を読み込む
        } catch (e) {
          print('Error showing rewarded ad: $e'); // デバッグ用
          setState(() {
            scheduleItems.clear(); // エラーの場合は直接削除
          });
        }
      } else {
        print('Rewarded ad not ready'); // デバッグ用
        setState(() {
          scheduleItems.clear();
        });
      }
    }
  }
}
