import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/models/on_boarding_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class OnBoardingController extends GetxController {
  var selectedPageIndex = 0.obs;

  bool get isLastPage => selectedPageIndex.value == onBoardingList.length - 1;
  var pageController = PageController();

  @override
  void onInit() {
    getOnBoardingData();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<OnBoardingModel> onBoardingList = <OnBoardingModel>[].obs;

  getOnBoardingData() async {
    await FireStoreUtils.getOnBoardingList().then((value) {
      onBoardingList.value = value;
    });
    // onBoardingList.add(OnBoardingModel(id: "",title: "Welcome to GroMart Store",description: "Manage your restaurant orders, reservations, and menu effortlessly all in one place.",image: "assets/images/image_1.png"));
    // onBoardingList.add(OnBoardingModel(id: "",title: "Streamline Your Operations",description: "Handle orders efficiently, update your menu in real-time, and keep track of your sales with ease.",image: "assets/images/image_2.png"));
    // onBoardingList.add(OnBoardingModel(id: "",title: "Engage with Your Customers",description: "Create promotions, respond to feedback, and provide a personalized dining experience.",image: "assets/images/image_3.png"));

    isLoading.value = false;
    update();
  }
}
