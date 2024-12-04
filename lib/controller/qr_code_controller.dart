import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/models/vendor_model.dart';

class QrCodeController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  GlobalKey globalKey = GlobalKey();

  RxBool isLoading = true.obs;

  Rx<VendorModel> vendorModel = VendorModel().obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }
    isLoading.value = false;
  }
}
