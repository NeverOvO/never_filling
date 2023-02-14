import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BlacklistPage extends StatefulWidget {
  final Map? arguments;
  const BlacklistPage({Key? key, this.arguments}) : super(key: key);

  @override
  createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {

  var databaseFactory = databaseFactoryFfi;
  var db;
  List blackList = [];

  @override
  void initState() {
    super.initState();
    readDB();
  }

  void readDB () async{
    db = await databaseFactory.openDatabase("blackList.db");
    blackList = await db.query('Black');
    setState(() {});
  }

  @override
  void dispose(){
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
          title: const Text("文件黑名单"),
        ),
        body:Column(
          children: [
            Container(
              color: Colors.yellow.withOpacity(0.5),
              padding: const EdgeInsets.fromLTRB(20, 10, 20,10),
              alignment: Alignment.centerLeft,
              child:Text("黑名单功能采用SqlLite实现，当文件名称加入黑名单列表后效果如下:\n"
                  "- 点击检索源文件地址目录后不会展示在列表;\n"
                  "- 点击操作已选择文件不会对其进行操作;\n"
                  "- 对于该目录下所有该名称文件均不会操作;\n"
                  "- 黑名单操作实时生效;",style: TextStyle(fontSize: 11,color: Colors.black.withOpacity(0.8)),)
            ),
            Container(
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
                    child:const Text("添加时间",style: TextStyle(fontSize: 11,color:Colors.black),),
                  ),
                  const VerticalDivider(width: 1,color: Colors.grey,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child:const Text("文件名",style: TextStyle(fontSize: 11,color:Colors.black),),
                    ),
                  ),
                ],
              ),

            ),
            const Divider(height: 1,color: Colors.grey,),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: blackList.length,
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
                          child:Text(blackList[index]["time"].toString(),style: const TextStyle(fontSize: 11,color:Colors.black),),
                        ),
                        const VerticalDivider(width: 1,color: Colors.grey,),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                            alignment: Alignment.centerLeft,
                            child:Text(blackList[index]["title"].toString(),style: const TextStyle(fontSize: 11,color:Colors.black),),
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
                                    child:Text("是否移除【${blackList[index]["title"].toString()}】",),
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
                                        await db.delete('Black', where: "id = ${blackList[index]["id"].toString()}");
                                        blackList = await db.query('Black');
                                        setState(() {});
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
        ),
      ),
    );
  }
}
