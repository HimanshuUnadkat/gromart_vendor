import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:store/app/Home_screen/home_screen.dart';
import 'package:store/app/product_screens/product_list_screen.dart';
import 'package:store/app/profile_screen/profile_screen.dart';
import 'package:store/app/wallet_screen/wallet_screen.dart';
import 'package:store/constant/constant.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxList pageList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    setSound();
    pageList.value = [
      const HomeScreen(),
      const ProductListScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];
    super.onInit();
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;

  setSound() async {
    try {
      print("--------->${audioPlayer.state}");
      audioPlayer.setSource(AssetSource("sound.mp3"));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      audioPlayer.stop();
      print("--------->${audioPlayer.state}");
    } catch (e) {
      print("--------->$e");
    }
  }
}
