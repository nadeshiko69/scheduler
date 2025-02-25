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
  final _formKey = GlobalKey<FormState>(); // フォームキーを追加
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
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '新しいタスクを追加',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'タスク名',
                    hintText: '例：仕事、勉強、運動',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タスク名を入力してください';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // フォーカスを解除してキーボードを閉じる
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '色を選択',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
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
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      '目標時間: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<int>(
                        value: _targetHours,
                        underline: Container(),
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
