import 'package:flutter/cupertino.dart';
import 'package:never_filling/KeepAlivePage.dart';
import 'package:never_filling/about/about_view.dart';
import 'package:never_filling/black_list/black_list_view.dart';
import 'package:never_filling/filling/filling_view.dart';

class IndexState {



  ///选择index
  late int selectedIndex;

  late List<Widget> pageList;
  late List pageListName;
  late PageController pageController;

  IndexState() {
    selectedIndex = 0;
    pageList = [
      KeepAlivePage(child: FillingPage()),
      BlackListPage(),
      AboutPage(),
    ];
    pageListName = [
      "文件自由",
      "文件黑名单",
      "关于与使用",
    ];
    //页面控制器
    pageController = PageController();
  }
}
