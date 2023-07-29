import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'filling_logic.dart';


class FillingPage extends StatelessWidget {
  final logic = Get.put(FillingLogic());
  final state = Get.find<FillingLogic>().state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        body:GetBuilder<FillingLogic>(builder: (logic) {
          return Row(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: const Text("源文件夹目录[支持拖入]:",style: TextStyle(fontSize: 11),),
                    ),
                    DropTarget(
                      onDragDone: (detail) {
                        logic.dropTargetFrom(detail);
                      },
                      onDragEntered: (detail) {
                        logic.changeDragging(true);
                      },
                      onDragExited: (detail) {
                        logic.changeDragging(false);
                      },
                      child: Container(
                        color: logic.dragging ? Colors.blue.withOpacity(0.4) : Colors.transparent,
                        child:Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 20),
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
                                    labelText: logic.fromHistory == "" ? '请选择源文件夹地址或拖动到此处' : "默认填入上次地址:${logic.fromHistory}",
                                  ),
                                  controller: logic.fromDirectoryPathController,
                                  autocorrect:false,
                                  style: const TextStyle(color: Colors.black,fontSize: 11),
                                ),
                              ),
                              InkWell(
                                onTap: () async{
                                  logic.retrieval();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: const Text("选择",style: TextStyle(color: Colors.white,fontSize: 12),),
                                ),
                              ),
                              const SizedBox(width: 10,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: const Text("目标文件夹目录[支持拖入]:",style: TextStyle(fontSize: 11),),
                    ),
                    DropTarget(
                      onDragDone: (detail) {
                        logic.dropTargetTo(detail);
                      },
                      onDragEntered: (detail) {
                        logic.changeDragging(true);
                      },
                      onDragExited: (detail) {
                        logic.changeDragging(false);
                      },
                      child: Container(
                        color: logic.dragging ? Colors.green.withOpacity(0.4) : Colors.transparent,
                        child:Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
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
                                    labelText: logic.toHistory == "" ? '请选择目标文件夹地址' : "默认填入上次地址:${logic.toHistory}",
                                  ),
                                  controller: logic.toDirectoryPathController,
                                  autocorrect:false,
                                  style: const TextStyle(color: Colors.black,fontSize: 11),
                                ),
                              ),
                              InkWell(
                                onTap: () async{
                                  logic.tapFilePickTo();
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: const Text("选择",style: TextStyle(color: Colors.white,fontSize: 12),),
                                ),
                              ),
                              const SizedBox(width: 10,),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async{
                                logic.cleanFill();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Text("清空输入",style: TextStyle(color: Colors.white,fontSize: 12),),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async{
                                logic.filling();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(10),
                                child: const Text("生成命令",style: TextStyle(color: Colors.white,fontSize: 12),),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: const Text("在右侧文件列表选择需要操作的文件后,点击'生成命令'进行操作\n具体操作查看侧边栏‘关于与使用 ’",style: TextStyle(fontSize: 9,color: Colors.black),),
                    ),

                    logic.command != "" ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      ),
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: SelectableText(logic.command,style: const TextStyle(fontSize: 11,color: Colors.black),),
                    ): const SizedBox(),

                  ],
                ),
              ),
              Offstage(
                offstage: !logic.mainLogic.showExtent,
                child: Container(
                  alignment: Alignment.center,
                  width: 500,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //每行三列
                            childAspectRatio: 3.5, //显示区域宽高相等
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: logic.fileLookupType!.length,
                          itemBuilder: (context, index) {
                            //文件类型
                            String type = logic.fileLookupType!.keys.toList()[index];
                            //一个分类下文件该操作的数量
                            int fileNum = logic.fileLookupList!.where((element) => element[1] == type).length - logic.fileLookupDelList.where((element) => element[1] == type).length;
                            return InkWell(
                              onTap:(){
                                //大类标签的全体选择
                                if(fileNum > 0){
                                  logic.tapFileLookupType(false,type);//大类删除
                                }else{
                                  logic.tapFileLookupType(true,type);//大类选择
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                                decoration: BoxDecoration(
                                  color: (fileNum > 0) ? Colors.amberAccent : const Color.fromRGBO(244, 244, 244, 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Text("$type - $fileNum/${logic.fileLookupList!.where((element) => element[1] == type).length}",
                                  style: const TextStyle(fontSize: 10, color:Colors.black87), maxLines: 1,overflow: TextOverflow.ellipsis,),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight: Radius.circular(10.0)),
                                ),
                                padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child:Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text("文件名称[类型|大小] => 源目录文件数: ${logic.fileLookupList!.length.toString()},已选择文件: ${logic.total.toString()}",style: const TextStyle(fontSize: 10,color: Colors.black),),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: const Text("文件路径",style: TextStyle(fontSize: 10,color: Colors.black),),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                      alignment: Alignment.center,
                                      child: const Text('拉黑',style: TextStyle(fontSize: 10,color: Colors.transparent),),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    //边框圆角设置
                                    border: Border.all(width: 1, color: Colors.amberAccent,),
                                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10.0),bottomRight: Radius.circular(10.0)),
                                  ),
                                  child: ListView.separated(
                                    itemCount: logic.fileLookupList!.length,
                                    itemBuilder: (context ,index){
                                      return InkWell(
                                        onTap: (){
                                          logic.fillDel(index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child:Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(logic.fileLookupList![index][0] + " ["+ logic.fileLookupList![index][1] + " | ${NumUtil.getNumByValueDouble(logic.fileLookupList![index][4], 2)}M" +  "]",
                                                    style: TextStyle(fontSize: 10,
                                                        color:logic.fileLookupDelList.contains(logic.fileLookupList![index]) ? Colors.grey : Colors.black),),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Text("源${logic.fileLookupList![index][2].toString().replaceAll(logic.fromDirectoryPathController.text, "")}",
                                                    style: TextStyle(fontSize: 10,color:logic.fileLookupDelList.contains(logic.fileLookupList![index]) ? Colors.grey : Colors.black),),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false, // user must tap button!
                                                    builder: (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        title: const Text('拉黑文件名',style: TextStyle(fontSize: 17),),
                                                        content:Container(
                                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                                          child:Text("是否确认【${logic.fileLookupList![index][0]}】拉黑文件名",),
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
                                                              logic.addBlackList(index);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                  alignment: Alignment.center,
                                                  child: const Text('拉黑',style: TextStyle(fontSize: 10,color: Colors.red),),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

}