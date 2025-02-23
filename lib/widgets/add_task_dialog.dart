// タスクを追加するダイアログ
// タスク名、色、目標時間を入力する
// 追加ボタンを押すと、タスクが追加される
// キャンセルボタンを押すと、ダイアログが閉じられる

import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  Color _selectedColor = Colors.blue;
  int _targetHours = 1;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しいタスクを追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タスク名',
                hintText: '例：仕事、勉強、運動',
              ),
            ),
            const SizedBox(height: 16),
            const Text('色を選択'),
            Wrap(
              spacing: 8,
              children: _colorOptions.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: color == _selectedColor
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('目標時間: '),
                DropdownButton<int>(
                  value: _targetHours,
                  items: List.generate(12, (index) => index + 1)
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text('$hours時間'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetHours = value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final newTask = Task(
                id: DateTime.now().toString(),
                title: _titleController.text,
                color: _selectedColor,
                targetDuration: Duration(hours: _targetHours),
              );
              Navigator.of(context).pop(newTask);
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
