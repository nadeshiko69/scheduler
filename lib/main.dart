import 'package:flutter/material.dart';
import 'screens/schedule_screen.dart'; // 追加
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  // asyncを追加
  // プラグインを使用する前にFlutterバインディングを確実に初期化
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  // 通知の初期化
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // バナーを非表示にする
      title: 'スケジューラー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScheduleScreen(), // MyHomePageからScheduleScreenに変更
    );
  }
}
