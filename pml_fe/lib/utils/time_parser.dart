import 'dart:async';
import '../services/notification_service.dart';

RegExp timeRegex = RegExp(r'(\d+)\s*(second|minute|hour|sec|min|hr)s?');

/// Extract time from step
String? extractTime(String step) {
  final match = timeRegex.firstMatch(step);
  if (match != null) {
    final value = match.group(1);
    final unit = match.group(2);
    return '$value $unit';
  }
  return null;
}

/// Convert extracted time into seconds
int parseTimeToSeconds(String time) {
  final match = timeRegex.firstMatch(time);
  if (match != null) {
    int value = int.parse(match.group(1)!);
    String unit = match.group(2)!;
    switch (unit) {
      case 'second':
      case 'sec':
        return value;
      case 'minute':
      case 'min':
        return value * 60;
      case 'hour':
      case 'hr':
        return value * 3600;
    }
  }
  return 0;
}

/// Start a timer and trigger notification and alarm
void startTimer(String time) {
  int totalSeconds = parseTimeToSeconds(time);
  if (totalSeconds > 0) {
    Timer(Duration(seconds: totalSeconds), () {
      NotificationService().showNotification(
        "Timer Done",
        "Time's up for this step!",
      );
      NotificationService().playAlarm();
    });
  }
}
