import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
