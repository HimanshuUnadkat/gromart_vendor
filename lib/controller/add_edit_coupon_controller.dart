import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/coupon_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class AddEditCouponController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> titleController = TextEditingController().obs;
  Rx<TextEditingController> couponCodeController = TextEditingController().obs;
  Rx<TextEditingController> priceController = TextEditingController().obs;
  Rx<TextEditingController> selectDateController = TextEditingController().obs;
  RxBool isActive = true.obs;
  RxBool isPublic = true.obs;
  RxString selectCouponType = "Fix Price".obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<CouponModel> couponModel = CouponModel().obs;
  RxList images = <dynamic>[].obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      couponModel.value = argumentData['couponModel'];
      titleController.value.text = couponModel.value.description.toString();
      couponCodeController.value.text = couponModel.value.code.toString();
      priceController.value.text = couponModel.value.discount.toString();
      selectDateController.value.text = Constant.timestampToDate(couponModel.value.expiresAt!);
      isActive.value = couponModel.value.isEnabled ?? false;
      isPublic.value = couponModel.value.isPublic ?? false;
      selectCouponType.value =
          couponModel.value.discountType == "Percentage" || couponModel.value.discountType == "Percent" ? "Percentage" : couponModel.value.discountType.toString();
      if (couponModel.value.image != null || couponModel.value.image!.isNotEmpty) {
        images.add(couponModel.value.image);
      }
    }
    isLoading.value = false;
  }

  saveCoupon() async {
    if (titleController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter title");
    } else if (couponCodeController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter coupon code");
    } else if (selectDateController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please select expire date");
    } else if (priceController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter price");
    } else {
      ShowToastDialog.showLoader("Please wait...");
      for (int i = 0; i < images.length; i++) {
        if (images[i].runtimeType == XFile) {
          String url = await Constant.uploadUserImageToFireStorage(
            File(images[i].path),
            "profileImage/${DateTime.now().toIso8601String()}",
            File(images[i].path).path.split('/').last,
          );
          images.removeAt(i);
          images.insert(i, url);
        }
      }

      couponModel.value.id = couponModel.value.id ?? Constant.getUuid();
      couponModel.value.code = couponCodeController.value.text.trim();
      couponModel.value.discount = priceController.value.text.trim();
      couponModel.value.discountType = selectCouponType.value;
      couponModel.value.image = images.isEmpty ? "" : images.first;
      couponModel.value.expiresAt = Timestamp.fromDate(DateFormat("MMM dd,yyyy").parse(selectDateController.value.text));
      couponModel.value.isEnabled = isActive.value;
      couponModel.value.isPublic = isPublic.value;
      couponModel.value.resturantId = Constant.userModel!.vendorID.toString();
      couponModel.value.description = titleController.value.text;
      await FireStoreUtils.setCoupon(couponModel.value).then(
        (value) {
          ShowToastDialog.closeLoader();
          Get.back(result: true);
        },
      );
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.clear();
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }
}
