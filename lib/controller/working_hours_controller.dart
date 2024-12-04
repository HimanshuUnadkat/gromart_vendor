import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/vendor_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class WorkingHoursController extends GetxController{

  RxBool isLoading = true.obs;
  RxList<WorkingHours> workingHours = <WorkingHours>[].obs;


  @override
  void onInit() {
    // TODO: implement onInit
    getVendor();
    super.onInit();
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  getVendor() async {
    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
          (value) {
        if (value != null) {
          vendorModel.value = value;
          if (vendorModel.value.workingHours == null || vendorModel.value.workingHours!.isEmpty) {
            workingHours.value = [
              WorkingHours(day: 'Monday'.tr, timeslot: []),
              WorkingHours(day: 'Tuesday'.tr, timeslot: []),
              WorkingHours(day: 'Wednesday'.tr, timeslot: []),
              WorkingHours(day: 'Thursday'.tr, timeslot: []),
              WorkingHours(day: 'Friday'.tr, timeslot: []),
              WorkingHours(day: 'Saturday'.tr, timeslot: []),
              WorkingHours(day: 'Sunday'.tr, timeslot: [])
            ];
          } else {
            workingHours.value = vendorModel.value.workingHours!;
          }
        }
      },
    );
    isLoading.value = false;
  }

  saveSpecialOffer() async {
    ShowToastDialog.showLoader("Please wait");

    FocusScope.of(Get.context!).requestFocus(FocusNode()); //remove focus
    vendorModel.value.workingHours = workingHours;

    await FireStoreUtils.updateVendor(vendorModel.value).then((value) async {
      ShowToastDialog.showToast("Working hours update successfully");
      ShowToastDialog.closeLoader();
    });
  }

  addValue(int index) {
    WorkingHours specialDiscountModel = workingHours[index];
    specialDiscountModel.timeslot!.add(Timeslot(from: '', to: ''));
    workingHours.removeAt(index);
    workingHours.insert(index, specialDiscountModel);
    update();
  }

  remove(int index, int timeSlotIndex) {
    WorkingHours specialDiscountModel = workingHours[index];
    specialDiscountModel.timeslot!.removeAt(timeSlotIndex);
    workingHours.removeAt(index);
    workingHours.insert(index, specialDiscountModel);
    update();
    update();
  }



}