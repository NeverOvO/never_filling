import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_logic.dart';


class AboutPage extends StatelessWidget {
  final logic = Get.put(AboutLogic());
  final state = Get.find<AboutLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: const Text("本软件仅需要文件读取权限,无需网络请求与权限,请注意个人数据安全!",style: TextStyle(fontSize: 12,color: Colors.redAccent),),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: const Text("关于黑名单功能:",style: TextStyle(fontSize: 12,color: Colors.black),),
          ),
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
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: const Text("软件问题:",style: TextStyle(fontSize: 12,color: Colors.black),),
          ),
          Row(
            children: [
              const Text("使用指南与服务支持地址:",style: TextStyle(fontSize: 11,color: Colors.black),),
              InkWell(
                onTap: () async{
                  if (!await launchUrl(Uri.parse('https://www.neverovo.xn--6qq986b3xl/2023/02/15/aboutneverfilling'))) {
                    throw Exception("无法打开");
                  }
                },
                child: const Text("点击这里",style: TextStyle(fontSize: 11,color: Colors.blue),),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              const Text("作者个人页:",style: TextStyle(fontSize: 11,color: Colors.black),),
              InkWell(
                onTap: () async{
                  if (!await launchUrl(Uri.parse('https://github.com/NeverOvO'))) {
                    throw Exception("无法打开");
                  }
                },
                child: const Text("点击这里",style: TextStyle(fontSize: 11,color: Colors.blue),),
              ),
            ],
          ),
        ],
      ),
    );
  }

}