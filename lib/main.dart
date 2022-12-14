import 'package:flutter/material.dart';
import 'package:never_filling/filling_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeverOuO Filling',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 15),
        )
      ),
      home: const FillingPage(),
    );
  }
}
