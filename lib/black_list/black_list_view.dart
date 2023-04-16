import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'black_list_logic.dart';

class BlackListPage extends StatelessWidget {
  final logic = Get.put(BlackListLogic());
  final state = Get.find<BlackListLogic>().state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      right: true,
      bottom: false,
      left: true,
      top: false,
      child: Scaffold(
        body: GetBuilder<BlackListLogic>(builder: (logic) {
          return Column(
            children: [
              Container(
                height: 40,
                color: Colors.amberAccent,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      alignment: Alignment.centerLeft,
                      child:const Text("添加时间",style: TextStyle(fontSize: 10,color:Colors.black),),
                    ),
                    const VerticalDivider(width: 1,color: Colors.grey,),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child:const Text("文件名",style: TextStyle(fontSize: 10,color:Colors.black),),
                      ),
                    ),
                  ],
                ),

              ),
              const Divider(height: 1,color: Colors.grey,),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: logic.mainLogic.blackList.length,
                  itemBuilder: (context ,index){
                    return Container(
                      height: 40,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            alignment: Alignment.centerLeft,
                            child:Text(logic.mainLogic.blackList[index]["time"].toString(),style: const TextStyle(fontSize: 10,color:Colors.black),),
                          ),
                          const VerticalDivider(width: 1,color: Colors.grey,),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                              alignment: Alignment.centerLeft,
                              child:Text(logic.mainLogic.blackList[index]["title"].toString(),style: const TextStyle(fontSize: 10,color:Colors.black),),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              showDialog(
                                context: context,
                                barrierDismissible: false, // user must tap button!
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: const Text('移除黑名单',style: TextStyle(fontSize: 17),),
                                    content:Container(
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                                      child:Text("是否移除【${logic.mainLogic.blackList[index]["title"].toString()}】",),
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
                                          logic.removeBlack(index);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text("移除",style: TextStyle(fontSize: 11,color:Colors.red),),
                          )
                        ],
                      ),

                    );
                  },
                  separatorBuilder: (context,index){
                    return const Divider(height: 1,color: Colors.grey,);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

}