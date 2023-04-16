import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:never_filling/index/index_view.dart';
import 'main_logic.dart';

class MainPage extends StatelessWidget {
  final logic = Get.put(MainLogic());
  final state = Get.find<MainLogic>().state;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NeverOuO Filling',
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.cyan),
            titleTextStyle: TextStyle(fontSize: 15,color: Colors.black),
            elevation: 0.0
        ),
      ),
      home: IndexPage(),
    );
  }

}