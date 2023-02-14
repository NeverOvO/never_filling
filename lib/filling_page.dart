import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:never_filling/blacklist.dart';
import 'package:neveruseless/neveruseless.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FillingPage extends StatefulWidget {
  final Map? arguments;
  const FillingPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _FillingPageState();
}

class _FillingPageState extends State<FillingPage> {

  String fromHistory = "";
  String toHistory = "";

  final TextEditingController fromDirectoryPathController = TextEditingController();
  final TextEditingController toDirectoryPathController = TextEditingController();

  bool _filePicktrue = true;

  Stream<FileSystemEntity>? fileList;

  List? filaName = [];

  Map? fileLookupType = {};
  List? fileLookupList = [];

  int total = 0;

  String command = "";

  var databaseFactory = databaseFactoryFfi;
  var db;
  List blackList = [];

  @override
  void initState() {
    super.initState();

    readHis();
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

    // String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择源文件夹",lockParentWindow: true);
    // Directory(fromHistory).list(recursive: true);
    // FilePicker.platform.getDirectoryPath(initialDirectory: fromHistory,lockParentWindow: false);

    setState(() {});

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
    queryDB();
  }

  void queryDB() async{
    blackList = await db.query('Black');
    setState(() {});
  }


  @override
  void dispose() async {
    await db.close();
    super.dispose();
  }

  bool _dragging = false;

  double _x = 0.0;
  double _y = 0.0;

  //文件检索
  void retrieval() async {
    command = "";
    total = 0;

    if(fromDirectoryPathController.text.isNotEmpty){
      fileList = Directory(fromDirectoryPathController.text).list(recursive: true);
    }else{
      if(fromHistory != ""){
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择源文件夹",lockParentWindow: true,initialDirectory: fromHistory);
        if(selectedDirectory != null){
          command = "";
          total = 0;
          fileLookupList!.clear();
          fileLookupType!.clear();
          fromDirectoryPathController.text = selectedDirectory;
          fileList = Directory(selectedDirectory).list(recursive: true);
          setState(() {});
        }
        // 为了保证文件安全以及符合沙盒模式要求下，让用户进行一次复选。
        // fileList = Directory(fromHistory).list(recursive: true);
      }else{
        return ;
      }
    }

    fileLookupList!.clear();
    fileLookupType!.clear();
    await for(FileSystemEntity fileSystemEntity in fileList!){
      if(lookupMimeType(fileSystemEntity.path) != null){
        if(!fileSystemEntity.path.toString().split("/").last.startsWith(".")){
          fileLookupType![lookupMimeType(fileSystemEntity.path)] = "true";
          String fileName = fileSystemEntity.path.toString().split("/").last;
          if(blackList.where((element) => element["title"] == fileName).isEmpty){
            fileLookupList!.add([fileName,lookupMimeType(fileSystemEntity.path),fileSystemEntity.parent.path,fileName]);
          }
          total = fileLookupList!.length;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        body:ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BlacklistPage()),).then((value) async{
                        queryDB();
                        retrieval();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        boxShadow: [BoxShadow(blurRadius: 3, spreadRadius: 0.5, color: Colors.grey.withOpacity(0.3), offset:const Offset(5,5)),],
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: const Text("文件黑名单",style: TextStyle(fontSize: 12),),
                    ),
                  ),
                ],
              ),
            ),

            DropTarget(
              onDragDone: (detail) {
                setState(() {
                  if(lookupMimeType(detail.files.first.path) != null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('请选择正确的文件夹'),
                        action: SnackBarAction(
                          label: '确认',
                          onPressed: () {},
                        ),
                      ),
                    );
                    return;
                  }else{
                    fromDirectoryPathController.text = detail.files.first.path;
                    retrieval();
                  }
                });
              },
              onDragEntered: (detail) {
                setState(() {
                  _dragging = true;
                });
              },
              onDragExited: (detail) {
                setState(() {
                  _dragging = false;
                });
              },
              child: Container(
                color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
                child:Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            enabledBorder: const UnderlineInputBorder(),
                            labelStyle: const TextStyle(color: Colors.grey),
                            labelText: fromHistory == "" ? '请选择源文件夹地址或拖动到此处' : "默认填入上次地址:$fromHistory",
                          ),
                          controller: fromDirectoryPathController,
                          autocorrect:false,
                          style: const TextStyle(color: Colors.black,fontSize: 11),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          if(_filePicktrue){
                            _filePicktrue = false;
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择源文件夹",lockParentWindow: true);
                            if(selectedDirectory != null){
                              command = "";
                              total = 0;
                              fileLookupList!.clear();
                              fileLookupType!.clear();
                              fromDirectoryPathController.text = selectedDirectory;
                              setState(() {});
                            }
                            _filePicktrue = true;
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: const Text("选择",style: TextStyle(color: Colors.white,fontSize: 12),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      retrieval();
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Text("检索源文件地址目录",style: TextStyle(color: Colors.white,fontSize: 12),),
                    ),
                  ),

                ],
              ),
            ),
            fileLookupType!.isNotEmpty ?
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 150,
                childAspectRatio: 5,
              ),
              itemCount: fileLookupType!.keys.length,
              itemBuilder: (context,index){
                return Container(
                  width: 150,
                  height: 30,
                  margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Row(
                    children:[
                      Checkbox(
                        value: fileLookupType!.values.toList()[index] == "true",
                        activeColor: Colors.blue, //选中时的颜色
                        onChanged:(value){
                          setState(() {
                            fileLookupType![fileLookupType!.keys.toList()[index]] = value.toString();
                            if(value == true){
                              total += fileLookupList!.where((element) => element[1] == fileLookupType!.keys.toList()[index]).length;
                            }else{
                              total -= fileLookupList!.where((element) => element[1] == fileLookupType!.keys.toList()[index]).length;
                            }
                          });
                        } ,
                      ),
                      Expanded(
                        child: Text(fileLookupType!.keys.toList()[index],style: const TextStyle(fontSize: 11,color: Colors.black),),
                      )
                    ],
                  ),
                );
              },
            ):const SizedBox(),
            fileLookupList!.isNotEmpty ?
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child:Container(
                            alignment: Alignment.centerLeft,
                            child:  const Text("文件名称",style: TextStyle(fontSize: 12,color: Colors.black),),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child:  const Text("文件类型",style: TextStyle(fontSize: 12,color: Colors.black),),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: const Text("文件路径",style: TextStyle(fontSize: 12,color: Colors.black),),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1,color: Colors.grey,),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      itemCount: fileLookupList!.length,
                      itemBuilder: (context ,index){
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onSecondaryTap: (){
                            showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(_x, _y, _x, _y),
                                items: [
                                  PopupMenuItem(
                                    value: 'Black_Add',
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: const Text('拉黑文件名',style: TextStyle(fontSize: 13),),
                                    ),
                                  ),
                                ]).then((value){
                                  if(value == "Black_Add"){
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          title: const Text('拉黑文件名',style: TextStyle(fontSize: 17),),
                                          content:Container(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                            child:Text("是否确认【${fileLookupList![index][0]}】拉黑文件名",),
                                          ),
                                          actions:<Widget>[
                                            CupertinoDialogAction(
                                              child: const Text('取消',style: TextStyle(color: Color.fromRGBO(215, 85, 82,  1)),),
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              },
                                            ),

                                            CupertinoDialogAction(
                                              child: const Text('确定'),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                                await db.insert('Black', {'title': fileLookupList![index][0] , 'time': DateTime.now().toString().split(".").first,'other' : ""});
                                                total = total - fileLookupList!.where((element) => element[0] == fileLookupList![index][0]).length;
                                                fileLookupList!.removeWhere((element) => element[0] == fileLookupList![index][0]);
                                                queryDB();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                            });
                          },
                          onSecondaryTapDown: (details){
                            setState(() {
                              _x = details.globalPosition.dx;
                              _y = details.globalPosition.dy;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child:Container(
                                    alignment: Alignment.centerLeft,
                                    child:  Text(fileLookupList![index][0],style: TextStyle(fontSize: 10,color:fileLookupType![fileLookupList![index][1]] == "true" ? Colors.blue : Colors.grey),),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child:  Text(fileLookupList![index][1],style: TextStyle(fontSize: 10,color:fileLookupType![fileLookupList![index][1]] == "true" ? Colors.blue : Colors.grey),),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(fileLookupList![index][2],style: TextStyle(fontSize: 10,color:fileLookupType![fileLookupList![index][1]] == "true" ? Colors.blue : Colors.grey),),
                                  ),
                                ),
                              ],
                            ),

                          ),
                        );
                      },
                      separatorBuilder: (context,index){
                        return const Divider(height: 1,color: Colors.grey,);
                      },
                    ),
                  ),
                ],
              ),
            ): const SizedBox(),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text("当前目录文件总数: ${fileLookupList!.length.toString()} ，已选择文件总数: ${total.toString()}",style: const TextStyle(fontSize: 11,color: Colors.black),),
            ),
            DropTarget(
              onDragDone: (detail) {
                setState(() {


                  if(lookupMimeType(detail.files.first.path) != null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('请选择正确的文件夹'),
                        action: SnackBarAction(
                          label: '确认',
                          onPressed: () {},
                        ),
                      ),
                    );
                    return;
                  }else{
                    toDirectoryPathController.text = detail.files.first.path;
                    setState(() {});
                  }
                });
              },
              onDragEntered: (detail) {
                setState(() {
                  _dragging = true;
                });
              },
              onDragExited: (detail) {
                setState(() {
                  _dragging = false;
                });
              },
              child: Container(
                color: _dragging ? Colors.green.withOpacity(0.4) : Colors.transparent,
                child:Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            enabledBorder: const UnderlineInputBorder(),
                            labelStyle: const TextStyle(color: Colors.grey),
                            labelText: toHistory == "" ? '请选择目标文件夹地址' : "默认填入上次地址:$toHistory",
                          ),
                          controller: toDirectoryPathController,
                          autocorrect:false,
                          style: const TextStyle(color: Colors.black,fontSize: 11),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          if(_filePicktrue){
                            _filePicktrue = false;
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择目标文件夹",lockParentWindow: true);
                            if(selectedDirectory != null){
                              toDirectoryPathController.text = selectedDirectory;
                            }
                            _filePicktrue = true;
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                          ),
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: const Text("选择",style: TextStyle(color: Colors.white,fontSize: 12),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async{

                      if(fromDirectoryPathController.text == "" && fromHistory == ""){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('请选择源文件夹'),
                            action: SnackBarAction(
                              label: '确认',
                              onPressed: () {},
                            ),
                          ),
                        );
                        return ;
                      }
                      if(toDirectoryPathController.text == "" && toHistory == ""){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('请选择目标文件夹'),
                            action: SnackBarAction(
                              label: '确认',
                              onPressed: () {},
                            ),
                          ),
                        );
                        return ;
                      }

                      if(fileLookupList!.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('请先点击"检索文件地址目录"或确认文件数量不为0'),
                            action: SnackBarAction(
                              label: '确认',
                              onPressed: () {},
                            ),
                          ),
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

                      List endFileName = [];
                      command = "";
                      if(totalEnd.isNotEmpty){
                        // if(repeat == 1){ // 重名文件保留版本
                        //   command = "mv '${totalEnd.first[2]}/${totalEnd.first[0]}' '$toAdd/${totalEnd.first[0].toString().replaceAll(".", "_0.")}'";
                        //   for(int i = 1;i<totalEnd.length ; i++){
                        //     command += " ; mv '${totalEnd[i][2]}/${totalEnd[i][0]}' '$toAdd/${totalEnd[i][0].toString().replaceAll(".", "_${i.toString()}.")}'";
                        //   }
                        // }else{ //重名文件不保留版本
                        //   command = "mv '${totalEnd.first[2]}/${totalEnd.first[0]}' '$toAdd/${totalEnd.first[0]}'";
                        //   for(int i = 1;i<totalEnd.length ; i++){
                        //     command += " ; mv '${totalEnd[i][2]}/${totalEnd[i][0]}' '$toAdd/${totalEnd[i][0]}'";
                        //   }
                        // }
                        //重名文件将会直接保留，在后续会添加时间戳保证非重复。
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('操作成功，命令已拷贝至剪切板'),
                          action: SnackBarAction(
                            label: '确认',
                            onPressed: () {},
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Text("操作已选择文件",style: TextStyle(color: Colors.white,fontSize: 12),),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: () async{
                      setState(() {
                        fromDirectoryPathController.text = "";
                        toDirectoryPathController.text = "";
                        fileLookupList!.clear();
                        fileLookupType!.clear();
                        command = "";
                        total = 0;
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Text("清空输入",style: TextStyle(color: Colors.white,fontSize: 12),),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: const Text("先点击'检索源文件地址目录'，选择需要的文件类型，再点击'操作已选择文件'进行操作",style: TextStyle(fontSize: 11,color: Colors.black),),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: const Text("请复制以下文本至命令行中，请勿使用SUDO权限，且迁移命令不可逆，请检查并确认路径是否正常",style: TextStyle(fontSize: 11,color: Colors.black),),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: SelectableText(command,style: const TextStyle(fontSize: 11,color: Colors.black),),
            ),

          ],
        ),
      ),
    );
  }
}
