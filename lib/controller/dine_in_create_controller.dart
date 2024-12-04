import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/vendor_model.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:uuid/uuid.dart';

class DineInCreateController extends GetxController {
  Rx<TextEditingController> priceController = TextEditingController().obs;
  Rx<TextEditingController> startDateController = TextEditingController().obs;
  Rx<TextEditingController> endDateDateController = TextEditingController().obs;

  Rx<VendorModel> vendorModel = VendorModel().obs;
  RxList images = <dynamic>[].obs;

  RxBool isLoading = true.obs;
  RxBool active = true.obs;
  RxBool isTimeValid = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getData();
    super.onInit();
  }

  getData() async {
    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
      (value) {
        if (value != null) {
          vendorModel.value = value;
          priceController.value.text = vendorModel.value.restaurantCost ?? '';

          if (vendorModel.value.openDineTime != null && vendorModel.value.openDineTime!.isNotEmpty) {
            startDateController.value.text = vendorModel.value.openDineTime.toString();
          }
          if (vendorModel.value.openDineTime != null && vendorModel.value.closeDineTime!.isNotEmpty) {
            endDateDateController.value.text = vendorModel.value.closeDineTime.toString();
          }

          active.value = vendorModel.value.enabledDiveInFuture ?? false;

          images.addAll(vendorModel.value.restaurantMenuPhotos ?? []);
        }
      },
    );
    isLoading.value = false;
  }

  saveDetails() async {
    ShowToastDialog.showLoader("Please wait..");

    for (int i = 0; i < images.length; i++) {
      if (images[i].runtimeType == XFile) {
        String url = await Constant.uploadUserImageToFireStorage(
          File(images[i].path),
          "menu/${const Uuid().v4()}",
          File(images[i].path).path.split('/').last,
        );
        images.removeAt(i);
        images.insert(i, url);
      }
    }

    vendorModel.value.restaurantCost = priceController.value.text;
    vendorModel.value.enabledDiveInFuture = active.value;
    vendorModel.value.openDineTime = startDateController.value.text;
    vendorModel.value.closeDineTime = endDateDateController.value.text;
    vendorModel.value.restaurantMenuPhotos = images;
    await FireStoreUtils.updateVendor(vendorModel.value).then((value) {
      ShowToastDialog.showToast("Dine In Details save");
    },);
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }
}
