import 'package:get/get.dart';
import 'package:never_filling/main/main_logic.dart';
import 'index_state.dart';

class IndexLogic extends GetxController {
  final IndexState state = IndexState();
  final mainLogic = Get.find<MainLogic>();
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


  ///切换tab
  void switchTap(int index) {
    if(state.selectedIndex == index){
      return;
    }
    if(index != 0){
      mainLogic.beSmall();
    }else{
      mainLogic.backSize();
    }
    state.selectedIndex = index;
    state.pageController.jumpToPage(index);
    update();
  }
}
