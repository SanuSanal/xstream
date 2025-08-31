import 'package:flutter/material.dart';
import 'package:xstream/screens/web_view_page.dart';
import 'package:xstream/service/log_service.dart';

void main() {
  LogService().log("App Started");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Acme'),
      home: const WebViewPage(),
    );
  }
}
