import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:store/constant/collection_name.dart';
import 'package:store/constant/constant.dart';
import 'package:store/models/order_model.dart';
import 'package:store/models/user_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> estimatedTimeController = TextEditingController().obs;

  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    setSound();
    super.onInit();
  }

  RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;

  Rx<UserModel> userModel = UserModel().obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getOrder();
    isLoading.value = false;
  }

  getOrder() async {
    FireStoreUtils.fireStore
        .collection(CollectionName.restaurantOrders)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (event) {
        allOrderList.clear();
        for (var element in event.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          allOrderList.add(orderModel);

          if (allOrderList.first.status == Constant.orderPlaced) {
            playSound(true);
          } else {
            playSound(false);
          }

          newOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderPlaced).toList();
          acceptedOrderList.value = allOrderList
              .where((p0) =>
                  p0.status == Constant.orderAccepted ||
                  p0.status == Constant.driverPending ||
                  p0.status == Constant.driverRejected ||
                  p0.status == Constant.orderShipped ||
                  p0.status == Constant.orderInTransit)
              .toList();
          completedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderCompleted).toList();
          rejectedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderRejected).toList();
        }
      },
    );
  }

  playSound(bool isPlay) async {
    if (isPlay) {
      await audioPlayer.resume();
    } else {
      await audioPlayer.stop();
    }
    print("0--------->${audioPlayer.state}");
  }

  setSound() async {
    final path = await rootBundle.load("assets/audio/sound.mp3");

    print("--------->${audioPlayer.state}");
    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        ctx: AudioContext(
            android: const AudioContextAndroid(
                contentType: AndroidContentType.music,
                isSpeakerphoneOn: true,
                stayAwake: false,
                usageType: AndroidUsageType.notification,
                audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback)));
    audioPlayer.stop();
    print("--------->${audioPlayer.state}");
  }

  @override
  void dispose() {
    playSound(false);
    super.dispose();
  }

  @override
  void onClose() {
    playSound(false);
    super.onClose();
  }
}
