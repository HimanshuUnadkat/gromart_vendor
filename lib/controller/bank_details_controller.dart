import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/user_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class BankDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> bankNameController = TextEditingController().obs;
  Rx<TextEditingController> branchNameController = TextEditingController().obs;
  Rx<TextEditingController> holderNameController = TextEditingController().obs;
  Rx<TextEditingController> accountNoController = TextEditingController().obs;
  Rx<TextEditingController> otherInfoController = TextEditingController().obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getCurrentUser();
    super.onInit();
  }

  saveBank() async {
    ShowToastDialog.showLoader("Please wait");
    userModel.value.userBankDetails ??= UserBankDetails();
    userModel.value.userBankDetails!.accountNumber = accountNoController.value.text;
    userModel.value.userBankDetails!.bankName = bankNameController.value.text;
    userModel.value.userBankDetails!.branchName = branchNameController.value.text;
    userModel.value.userBankDetails!.holderName = holderNameController.value.text;
    userModel.value.userBankDetails!.otherDetails = otherInfoController.value.text;

    await FireStoreUtils.updateUser(userModel.value).then(
      (value) {
        ShowToastDialog.closeLoader();
        Get.back();
      },
    );
  }

  getCurrentUser() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
          if (userModel.value.userBankDetails != null) {
            bankNameController.value.text = userModel.value.userBankDetails!.bankName.toString();
            branchNameController.value.text = userModel.value.userBankDetails!.branchName.toString();
            holderNameController.value.text = userModel.value.userBankDetails!.holderName.toString();
            accountNoController.value.text = userModel.value.userBankDetails!.accountNumber.toString();
            otherInfoController.value.text = userModel.value.userBankDetails!.otherDetails.toString();
          }
        }
      },
    );
    isLoading.value = false;
  }
}
