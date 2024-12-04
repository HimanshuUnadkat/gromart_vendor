import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/vendor_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class SpecialDiscountController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<SpecialDiscount> specialDiscount = <SpecialDiscount>[].obs;

  List<String> discountType = ['Delivery Discount'.tr].obs;
  List<String> type = [Constant.currencyModel!.symbol!, '%'];

  @override
  void onInit() {
    // TODO: implement onInit
    getVendor();
    super.onInit();
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;
  RxBool isSpecialSwitched = false.obs;

  getVendor() async {
    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
      (value) {
        if (value != null) {
          vendorModel.value = value;

          if (vendorModel.value.specialDiscount == null || vendorModel.value.specialDiscount!.isEmpty) {
            specialDiscount.value = [
              SpecialDiscount(day: 'Monday'.tr, timeslot: []),
              SpecialDiscount(day: 'Tuesday'.tr, timeslot: []),
              SpecialDiscount(day: 'Wednesday'.tr, timeslot: []),
              SpecialDiscount(day: 'Thursday'.tr, timeslot: []),
              SpecialDiscount(day: 'Friday'.tr, timeslot: []),
              SpecialDiscount(day: 'Saturday'.tr, timeslot: []),
              SpecialDiscount(day: 'Sunday'.tr, timeslot: [])
            ];
          } else {
            specialDiscount.value = vendorModel.value.specialDiscount!;
          }
          isSpecialSwitched.value = vendorModel.value.specialDiscountEnable ?? false;
        }
      },
    );

    isLoading.value = false;
  }

  saveSpecialOffer() async {
    ShowToastDialog.showLoader("Please wait");

    FocusScope.of(Get.context!).requestFocus(FocusNode()); //remove focus
    vendorModel.value.specialDiscount = specialDiscount;
    vendorModel.value.specialDiscountEnable = isSpecialSwitched.value;

    await FireStoreUtils.updateVendor(vendorModel.value).then((value) async {
      ShowToastDialog.showToast("Special discount update successfully");
      ShowToastDialog.closeLoader();
    });
  }

  addValue(int index) {
    SpecialDiscount specialDiscountModel = specialDiscount[index];
    specialDiscountModel.timeslot!.add(SpecialDiscountTimeslot(from: '', to: '', discount: '', type: 'percentage', discountType: 'delivery'));
    specialDiscount.removeAt(index);
    specialDiscount.insert(index, specialDiscountModel);
    update();
  }

  changeValue(int index,int indexTimeSlot,String value) {
    SpecialDiscount specialDiscountModel = specialDiscount[index];

    List<SpecialDiscountTimeslot>? list = specialDiscountModel.timeslot!;

    SpecialDiscountTimeslot discountTimeslot = list[indexTimeSlot];
    discountTimeslot.type = value;
    list.removeAt(indexTimeSlot);
    list.insert(indexTimeSlot, discountTimeslot);

    specialDiscountModel.timeslot = list;
    specialDiscount.removeAt(index);
    specialDiscount.insert(index, specialDiscountModel);
    update();
  }

  remove(int index, int timeSlotIndex) {
    SpecialDiscount specialDiscountModel = specialDiscount[index];
    specialDiscountModel.timeslot!.removeAt(timeSlotIndex);
    specialDiscount.removeAt(index);
    specialDiscount.insert(index, specialDiscountModel);
    update();
    update();
  }
}
