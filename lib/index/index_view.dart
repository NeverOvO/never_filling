import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'index_logic.dart';

class IndexPage extends StatelessWidget {
  final logic = Get.put(IndexLogic());
  final state = Get.find<IndexLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GetBuilder<IndexLogic>(builder: (logic) {
            return Text(state.pageListName[state.selectedIndex]);
          }),
        ),
        drawer: Drawer(
          semanticLabel: "导航栏",
          width: 150,
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color.fromRGBO(255,192,203,0.4), Colors.white,],
                  stops: [0,0.3,]
              ),
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
            ),
            alignment: Alignment.center,
            child: ListView(
              children: <Widget>[
                ListTile(title: const Text('文件自由', style: TextStyle(color: Colors.black, fontSize: 14)),
                  onTap: () {
                    logic.switchTap(0);
                    Navigator.pop(context);
                  },
                ),
                ListTile(title:  const Text('文件黑名单', style: TextStyle(color: Colors.black, fontSize: 14)),
                  onTap: () {
                    logic.switchTap(1);
                    Navigator.pop(context);
                  },
                ),
                ListTile(title: const Text('关于与使用', style: TextStyle(color: Colors.black, fontSize: 14)),
                  onTap: () {
                    logic.switchTap(2);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      body:GetBuilder<IndexLogic>(builder: (logic) {
        return PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.pageList.length,
          itemBuilder: (context, index) => state.pageList[index],
          controller: state.pageController,
        );
      }),
    );
  }

}