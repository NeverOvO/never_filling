import 'dart:ui';

import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'main_state.dart';

class MainLogic extends GetxController {
  final MainState state = MainState();
  bool showExtent = false;
  var databaseFactory = databaseFactoryFfi;
  var db;
  List blackList = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    readHis();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() async{
    // TODO: implement onClose
    await db.close();
    super.onClose();
  }

  void onFirst(){

  }

  void readHis() async{

    db = await databaseFactory.openDatabase("blackList.db");
    //检查表是否存在
    var sql ="SELECT * FROM sqlite_master WHERE TYPE = 'table' AND NAME = 'Black'";
    var res = await db.rawQuery(sql);
    var returnRes = res!=null && res.length > 0;

    if(!returnRes){
      await db.execute(
          '''
          CREATE TABLE Black (
              id INTEGER PRIMARY KEY,
              title TEXT,
              time TEXT,
              other TEXT
          )
          '''
      );
    }
    blackList = await db.query('Black');
    update();
  }

  void queryDB() async{
    blackList = await db.query('Black');
    update();
  }

  void beBig() async{
    if(!showExtent){
      windowManager.setSize( const Size(900, 700),animate: false);
      showExtent = true;
      update();
    }
  }

  //变小
  void beSmall({bool small = false}) async{
    if(small){
      showExtent = false;
      update();
      Future.delayed(const Duration(milliseconds: 100)).then((onValue) async{
        windowManager.setSize(const Size(400, 700),animate: true);
        update();
      });
    }else{
      windowManager.setSize(const Size(400, 700),animate: true);
      update();
    }
  }

  //恢复
  void backSize() async {
    if(showExtent){
      windowManager.setSize( const Size(900, 700),animate: false);
      update();
    }else{
      windowManager.setSize(const Size(400, 700),animate: true);
      update();
    }
  }
}
