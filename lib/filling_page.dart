import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

class FillingPage extends StatefulWidget {
  final Map? arguments;
  const FillingPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _FillingPageState();
}

class _FillingPageState extends State<FillingPage> {

  final TextEditingController fromDirectoryPathController = TextEditingController();
  final TextEditingController toDirectoryPathController = TextEditingController();

  Stream<FileSystemEntity>? fileList;

  List? filaName = [];

  Map? fileLookupType = {};
  List? fileLookupList = [];

  int total = 0;

  int repeat = 0;//0 不保留 1 保留

  String command = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("文件归档"),
        ),
        body:ListView(
          children: [

            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        enabledBorder: UnderlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: '请输入或选择源文件夹地址',
                      ),
                      controller: fromDirectoryPathController,
                      autocorrect:false,
                      style: const TextStyle(color: Colors.black,fontSize: 11),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择源文件夹",lockParentWindow: true);
                      if(selectedDirectory != null){
                        command = "";
                        total = 0;
                        toDirectoryPathController.text = "";
                        fileLookupList!.clear();
                        fileLookupType!.clear();
                        fromDirectoryPathController.text = selectedDirectory;
                        setState(() {});
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
                      child: const Text("选择",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async{
                      command = "";
                      total = 0;
                      if(fromDirectoryPathController.text.isNotEmpty){
                        fileList = Directory(fromDirectoryPathController.text).list(recursive: true);
                        fileLookupList!.clear();
                        fileLookupType!.clear();
                        await for(FileSystemEntity fileSystemEntity in fileList!){
                          if(lookupMimeType(fileSystemEntity.path) != null){
                            if(!fileSystemEntity.path.toString().split("/").last.startsWith(".")){
                              fileLookupType![lookupMimeType(fileSystemEntity.path)] = "true";
                              fileLookupList!.add([fileSystemEntity.path.toString().split("/").last,lookupMimeType(fileSystemEntity.path),fileSystemEntity.parent.path.replaceAll(" ", "\\ ")]);
                              total = fileLookupList!.length;
                            }
                          }
                        }
                        setState(() {});
                      }

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: const Text("检索源文件地址目录",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: () async{
                      command = "";
                      setState(() {
                        repeat == 0 ? repeat = 1 : repeat = 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: repeat == 0 ? Colors.blue : Colors.green,
                        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(repeat == 0 ? "重名文件:不保留" : "重名文件:保留",style: const TextStyle(color: Colors.white),),
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
              height: 300,
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
                  Expanded(
                    child: ListView.separated(
                      // physics: NeverScrollableScrollPhysics(),
                      // shrinkWrap: true,
                      itemCount: fileLookupList!.length,
                      itemBuilder: (context ,index){
                        return Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                                  child: SelectableText(fileLookupList![index][2],style: TextStyle(fontSize: 10,color:fileLookupType![fileLookupList![index][1]] == "true" ? Colors.blue : Colors.grey),),
                                ),
                              ),
                            ],
                          ),

                        );
                      },
                      separatorBuilder: (context,index){
                        return const Divider(height: 1,color: Colors.grey,);
                      },
                    ),
                  )
                ],
              ),
            ): const SizedBox(),

            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Text("当前目录文件总数: ${fileLookupList!.length.toString()} ，已选择文件总数: ${total.toString()}"

                ,style: const TextStyle(fontSize: 11,color: Colors.black),),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        enabledBorder: UnderlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.grey),
                        labelText: '请输入/选择/新建目标文件夹地址',
                      ),
                      controller: toDirectoryPathController,
                      autocorrect:false,
                      style: const TextStyle(color: Colors.black,fontSize: 11),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async{
                      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle:"选择目标文件夹",lockParentWindow: true);
                      if(selectedDirectory != null){
                        toDirectoryPathController.text = selectedDirectory;
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
                      child: const Text("选择",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async{

                      if(toDirectoryPathController.text == ""){
                        return ;
                      }

                      List? totalEnd = [];
                      fileLookupType!.forEach((key, value) {
                        if(value == "true"){
                          totalEnd.addAll(fileLookupList!.where((element) => element[1] == key));
                        }
                      });

                      command = "";
                      if(totalEnd.isNotEmpty){
                        if(totalEnd.length == 1){
                          command = "${"mv " + totalEnd.first[2] + "/'" + totalEnd.first[0] +"'"  + " " + toDirectoryPathController.text.replaceAll(" ", "\\ ") + '/' + "'" + totalEnd.first[0]}'";
                        }else{

                          if(repeat == 1){
                            command = "mv " + totalEnd.first[2] + "/'" + totalEnd.first[0] +"'" + " " + toDirectoryPathController.text.replaceAll(" ", "\\ ") + '/' + "'" +(totalEnd.first[0].toString().replaceAll(".", "_0."))+"'";
                            for(int i = 1;i<totalEnd.length ; i++){
                              command += " ; mv " + totalEnd[i][2] + "/'" + totalEnd[i][0] +"'" + " " + toDirectoryPathController.text.replaceAll(" ", "\\ ") + '/' + "'" + (totalEnd[i][0].toString().replaceAll(".", "_${i.toString()}."))+"'";
                            }
                          }else{
                            command = "${"mv " + totalEnd.first[2] + "/'" + totalEnd.first[0] +"'"  + " " + toDirectoryPathController.text.replaceAll(" ", "\\ ") + '/' + "'" +  totalEnd.first[0]}'";
                            for(int i = 1;i<totalEnd.length ; i++){
                              command += "${" ; mv " + totalEnd[i][2] + "/'" + totalEnd[i][0] +"'"  + " " + toDirectoryPathController.text.replaceAll(" ", "\\ ") + '/' + "'" + totalEnd[i][0]}'";
                            }
                          }
                        }
                      }//mv /Users/Volumes/Seagate14T/硬盘下载/2304/《最新 精品卐網紅 洩密》 (7).mp4 /Users/Volumes/Seagate14T/硬盘下载/Demo/《最新 精品卐網紅 洩密》 (7)_0.mp4

                      print(command);
                      Clipboard.setData(ClipboardData(text: command));
                      setState(() {});
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: const Text("操作已选择文件",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
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
