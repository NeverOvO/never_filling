import 'package:get/get.dart';
import 'package:never_filling/main/main_logic.dart';
import 'black_list_state.dart';

class BlackListLogic extends GetxController {
  final BlackListState state = BlackListState();
  final mainLogic = Get.find<MainLogic>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    update();
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

  void removeBlack(int index) async{
    await mainLogic.db.delete('Black', where: "id = ${mainLogic.blackList[index]["id"].toString()}");
    mainLogic.queryDB();
    update();
  }
}
