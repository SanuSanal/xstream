import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();
  final _logQueue = ListQueue<String>(1000);

  final ValueNotifier<List<String>> logs = ValueNotifier([]);

  void log(String message) {
    final timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    if (_logQueue.length == 1000) _logQueue.removeFirst();
    _logQueue.add("[$timestamp] $message");
    logs.value = _logQueue.toList();
  }

  void clear() {
    logs.value = [];
  }
}
