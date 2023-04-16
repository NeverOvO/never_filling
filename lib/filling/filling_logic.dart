import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:never_filling/main/main_logic.dart';
import 'package:neveruseless/neveruseless.dart';

import 'filling_state.dart';

class FillingLogic extends GetxController {
  final FillingState state = FillingState();
  final mainLogic = Get.find<MainLogic>();

  String fromHistory = "";
  String toHistory = "";

  final TextEditingController fromDirectoryPathController = TextEditingController();
  final TextEditingController toDirectoryPathController = TextEditingController();

  bool filePicktrue = true;


  //文件检索
  void retrieval() async {
    command = "";
    total = 0;

    if(filePicktrue){
      filePicktrue = false;
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择源文件夹",lockParentWindow: true,initialDirectory: fromHistory);
      filePicktrue = true;
      if(selectedDirectory != null){
        command = "";
        total = 0;
        fileLookupList!.clear();
        fileLookupType!.clear();
        fromDirectoryPathController.text = selectedDirectory;
        fileList = Directory(selectedDirectory).list(recursive: true);
        update();
      }else{
        return;
      }
    }

    fileLookupList!.clear();
    fileLookupType!.clear();
    await for(FileSystemEntity fileSystemEntity in fileList!){
      if(lookupMimeType(fileSystemEntity.path) != null){
        if(!fileSystemEntity.path.toString().split("/").last.startsWith(".")){
          fileLookupType![lookupMimeType(fileSystemEntity.path)] = "true";
          String fileName = fileSystemEntity.path.toString().split("/").last;
          double fileSize = 0.0;
          try{
            fileSize = File(fileSystemEntity.path.toString()).lengthSync() / 1024 / 1024;
          }catch(e){
            fileSize = 0.0;
          }
          if(mainLogic.blackList.where((element) => element["title"] == fileName).isEmpty){
            fileLookupList!.add([fileName,lookupMimeType(fileSystemEntity.path),fileSystemEntity.parent.path,fileName,fileSize]);
          }
          total = fileLookupList!.length;
        }
      }
    }
    update();
    mainLogic.beBig();
  }

  //文件检索1
  void retrievalOne() async {
    command = "";
    total = 0;

    if(fromDirectoryPathController.text.isNotEmpty){
      fileList = Directory(fromDirectoryPathController.text).list(recursive: true);
    }else{
      return;
    }

    fileLookupList!.clear();
    fileLookupType!.clear();
    await for(FileSystemEntity fileSystemEntity in fileList!){
      if(lookupMimeType(fileSystemEntity.path) != null){
        if(!fileSystemEntity.path.toString().split("/").last.startsWith(".")){
          fileLookupType![lookupMimeType(fileSystemEntity.path)] = "true";
          String fileName = fileSystemEntity.path.toString().split("/").last;
          double fileSize = 0.0;
          try{
            fileSize = File(fileSystemEntity.path.toString()).lengthSync() / 1024 / 1024;
          }catch(e){
            fileSize = 0.0;
          }
          if(mainLogic.blackList.where((element) => element["title"] == fileName).isEmpty){
            fileLookupList!.add([fileName,lookupMimeType(fileSystemEntity.path),fileSystemEntity.parent.path,fileName,fileSize]);
          }
          total = fileLookupList!.length;
        }
      }
    }
    update();
    mainLogic.beBig();
  }

  void tapFilePickTo() async{
    if(filePicktrue){
      filePicktrue = false;
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择目标文件夹",lockParentWindow: true);
      if(selectedDirectory != null){
        toDirectoryPathController.text = selectedDirectory;
      }
      filePicktrue = true;
      update();
    }
  }



  Stream<FileSystemEntity>? fileList;

  List? filaName = [];

  Map? fileLookupType = {};
  List? fileLookupList = [];

  void tapFileLookupType(bool value,int index){
    fileLookupType![fileLookupType!.keys.toList()[index]] = value.toString();
    if(value == true){
      total += fileLookupList!.where((element) => element[1] == fileLookupType!.keys.toList()[index]).length;
    }else{
      total -= fileLookupList!.where((element) => element[1] == fileLookupType!.keys.toList()[index]).length;
    }
    update();
  }

  int total = 0;

  String command = "";


  void addBlackList(int index) async{
    await mainLogic.db.insert('Black', {'title': fileLookupList![index][0] , 'time': DateTime.now().toString().split(".").first,'other' : ""});
    total = total - fileLookupList!.where((element) => element[0] == fileLookupList![index][0]).length;
    fileLookupList!.removeWhere((element) => element[0] == fileLookupList![index][0]);
    mainLogic.queryDB();
    update();
  }

  void onSecondaryTapDown(var details){
    x = details.globalPosition.dx;
    y = details.globalPosition.dy;
  }

  void readHis() async{
    //读取上次操作的位置 如果没有选择则进行默认处理
    fromHistory = await neverLocalStorageRead("FromHistory");
    if(fromHistory == "null"){
      fromHistory = "";
    }
    toHistory = await neverLocalStorageRead("ToHistory");
    if(toHistory == "null"){
      toHistory = "";
    }

    update();

  }

  bool dragging = false;

  double x = 0.0;
  double y = 0.0;


  void dropTargetFrom(var detail){
    if(lookupMimeType(detail.files.first.path) != null){
      Get.snackbar(
        "源目录错误",
        "请选择正确的文件夹目录",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("源目录错误",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请选择正确的文件夹目录",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return;
    }else{
      fromDirectoryPathController.text = detail.files.first.path;
      retrievalOne();
      update();
    }
  }

  void dropTargetTo(var detail){
    if(lookupMimeType(detail.files.first.path) != null){
      Get.snackbar(
        "目标目录错误",
        "请选择正确的文件夹目录",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("目标目录错误",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请选择正确的文件夹目录",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return;
    }else{
      toDirectoryPathController.text = detail.files.first.path;
      update();
    }
  }

  void changeDragging(bool tap){
    dragging = tap;
    update();
  }

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
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void fillDel(int index){
    if(fileLookupType![fileLookupList![index][1]] == "true"){
      fileLookupType![fileLookupList![index][1]] = "false";
    }else{
      fileLookupType![fileLookupList![index][1]] = "true";
    }
    update();
  }

  void filling() async{

    if(fromDirectoryPathController.text == "" && fromHistory == ""){
      Get.snackbar(
        "源目录未选择",
        "请选择源文件夹",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("源目录未选择",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请选择源文件夹",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return ;
    }
    if(toDirectoryPathController.text == "" && toHistory == ""){
      Get.snackbar(
        "目标目录未选择",
        "请选择目标文件夹",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("目标目录未选择",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请选择目标文件夹",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return ;
    }

    if(fileLookupList!.isEmpty){
      Get.snackbar(
        "操作错误",
        "请先点击'检索文件地址目录'或确认文件数量不为0",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("操作错误",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请先点击'检索文件地址目录'或确认文件数量不为0",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return ;
    }

    String toAdd = toDirectoryPathController.text == "" ? toHistory : toDirectoryPathController.text;

    List? totalEnd = [];
    fileLookupType!.forEach((key, value) {
      if(value == "true"){
        totalEnd.addAll(fileLookupList!.where((element) => element[1] == key));
      }
    });

    if(totalEnd.isEmpty){
      Get.snackbar(
        "操作文件为空",
        "请先点击'检索文件地址目录'或确认文件数量不为0",
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        titleText: const Text("操作文件为空",style: TextStyle(color: Colors.black,fontSize: 14),),
        messageText: const Text("请先点击'检索文件地址目录'或确认文件数量不为0",style: TextStyle(color: Colors.red,fontSize: 12),),
      );
      return;
    }

    List endFileName = [];
    command = "";
    if(totalEnd.isNotEmpty){
      command = "mv '${totalEnd.first[2]}/${totalEnd.first[0]}' '$toAdd/${totalEnd.first[0]}'";
      endFileName.add(totalEnd.first[0]);
      for(int i = 1;i<totalEnd.length ; i++){
        if(endFileName.contains(totalEnd[i][0])){
          command += " ; mv '${totalEnd[i][2]}/${totalEnd[i][0]}' '$toAdd/${totalEnd[i][0].toString().replaceAll(".", "_${DateTime.now().microsecondsSinceEpoch.toString()}.")}'";
        }else{
          command += " ; mv '${totalEnd[i][2]}/${totalEnd[i][0]}' '$toAdd/${totalEnd[i][0]}'";
          endFileName.add(totalEnd[i][0]);
        }
      }
    }

    endFileName.clear();

    String fromAdd = fromDirectoryPathController.text == "" ? fromHistory : fromDirectoryPathController.text;
    await neverLocalStorageWrite("FromHistory",fromAdd);
    await neverLocalStorageWrite("ToHistory",toAdd);


    Clipboard.setData(ClipboardData(text: command));
    Get.snackbar(
      "操作已选择文件",
      "操作成功，命令已拷贝至剪切板",
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      titleText: const Text("操作已选择文件",style: TextStyle(color: Colors.black,fontSize: 14),),
      messageText: const Text("操作成功，命令已拷贝至剪切板",style: TextStyle(color: Colors.green,fontSize: 12),),
    );
    update();
  }

  void cleanFill(){
    fromDirectoryPathController.text = "";
    toDirectoryPathController.text = "";
    fileLookupList!.clear();
    fileLookupType!.clear();
    command = "";
    total = 0;
    mainLogic.beSmall(small: true);
    update();
  }
}
