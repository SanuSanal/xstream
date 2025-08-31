import 'package:flutter/material.dart';
import 'package:xstream/service/log_service.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logService = LogService();

    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: logService.logs,
        builder: (context, logs, _) {
          final logText = logs.join("\n");

          return Container(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SelectableText(
                  logText,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
