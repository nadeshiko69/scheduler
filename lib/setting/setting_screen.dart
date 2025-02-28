// 設定画面
// 開始時刻と終了時刻を設定できる
// 設定を保存できる

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/extended_time_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ExtendedTimeOfDay _startTime = const ExtendedTimeOfDay(hour: 6, minute: 0);
  ExtendedTimeOfDay _endTime = const ExtendedTimeOfDay(hour: 22, minute: 0);

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startTime = ExtendedTimeOfDay(
        hour: prefs.getInt('startHour') ?? 6,
        minute: prefs.getInt('startMinute') ?? 0,
      );
      _endTime = ExtendedTimeOfDay(
        hour: prefs.getInt('endHour') ?? 22,
        minute: prefs.getInt('endMinute') ?? 0,
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startHour', _startTime.hour);
    await prefs.setInt('startMinute', _startTime.minute);
    await prefs.setInt('endHour', _endTime.hour);
    await prefs.setInt('endMinute', _endTime.minute);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('開始時刻'),
            subtitle: Text(_startTime.format24Hour()),
            onTap: () async {
              final picked = await showDialog<ExtendedTimeOfDay>(
                context: context,
                builder: (context) => ExtendedTimePicker(
                  initialTime: _startTime,
                ),
              );
              if (picked != null) {
                setState(() => _startTime = picked);
                // 開始時刻が変更された場合、終了時刻も調整
                if (_endTime.hour < picked.hour ||
                    (_endTime.hour == picked.hour &&
                        _endTime.minute <= picked.minute)) {
                  _endTime = ExtendedTimeOfDay(
                    hour: picked.hour + 24,
                    minute: _endTime.minute,
                  );
                }
                await _saveSettings();
              }
            },
          ),
          ListTile(
            title: const Text('終了時刻'),
            subtitle: Text(_endTime.hour >= 24
                ? '${_endTime.format24Hour()} (翌日 ${_endTime.hour - 24}:${_endTime.minute.toString().padLeft(2, '0')})'
                : _endTime.format24Hour()),
            onTap: () async {
              final picked = await showDialog<ExtendedTimeOfDay>(
                context: context,
                builder: (context) => ExtendedTimePicker(
                  initialTime: _endTime,
                  startTime: _startTime, // 開始時刻を渡す
                ),
              );
              if (picked != null) {
                setState(() => _endTime = picked);
                await _saveSettings();
              }
            },
          ),
        ],
      ),
    );
  }
}
