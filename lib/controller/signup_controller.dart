import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store/app/auth_screen/login_screen.dart';
import 'package:store/app/dash_board_screens/dash_board_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/user_model.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  Rx<TextEditingController> firstNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;
  Rx<TextEditingController> conformPasswordEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;
  RxBool conformPasswordVisible = true.obs;

  RxString type = "".obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      userModel.value = argumentData['userModel'];
      if (type.value == "mobileNumber") {
        phoneNUmberEditingController.value.text = userModel.value.phoneNumber.toString();
        countryCodeEditingController.value.text = userModel.value.countryCode.toString();
      }
    }
  }

  signUpWithEmailAndPassword() async {
    signUp();
  }

  signUp() async {
    ShowToastDialog.showLoader("Please wait");
    if (type.value == "mobileNumber") {
      userModel.value.firstName = firstNameEditingController.value.text.toString();
      userModel.value.lastName = lastNameEditingController.value.text.toString();
      userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
      userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
      userModel.value.role = Constant.userRoleVendor;
      userModel.value.fcmToken = await NotificationService.getToken();
      userModel.value.active = Constant.autoApproveRestaurant == true ? true : false;
      userModel.value.countryCode = countryCodeEditingController.value.text;
      userModel.value.isDocumentVerify = Constant.isRestaurantVerification == true ? false : true;
      userModel.value.createdAt = Timestamp.now();

      await FireStoreUtils.updateUser(userModel.value).then(
        (value) {
          if (Constant.autoApproveRestaurant == true) {
            Get.offAll(const DashBoardScreen());
          } else {
            ShowToastDialog.showToast("Thank you for sign up, your application is under approval so please wait till that approve.");
            Get.offAll(const LoginScreen());
          }
        },
      );
    } else {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );
        if (credential.user != null) {
          userModel.value.id = credential.user!.uid;
          userModel.value.firstName = firstNameEditingController.value.text.toString();
          userModel.value.lastName = lastNameEditingController.value.text.toString();
          userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
          userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
          userModel.value.role = Constant.userRoleVendor;
          userModel.value.fcmToken = await NotificationService.getToken();
          userModel.value.active = Constant.autoApproveRestaurant == true ? true : false;
          userModel.value.isDocumentVerify = Constant.isRestaurantVerification == true ? false : true;
          userModel.value.countryCode = countryCodeEditingController.value.text;
          userModel.value.createdAt = Timestamp.now();

          await FireStoreUtils.updateUser(userModel.value).then(
            (value) async {
              if (Constant.autoApproveRestaurant == true) {
                Get.offAll(const DashBoardScreen());
              } else {
                ShowToastDialog.showToast("Thank you for sign up, your application is under approval so please wait till that approve.");
                Get.offAll(const LoginScreen());
              }
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ShowToastDialog.showToast("The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          ShowToastDialog.showToast("The account already exists for that email.");
        } else if (e.code == 'invalid-email') {
          ShowToastDialog.showToast("Enter email is Invalid");
        }
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
      }
    }

    ShowToastDialog.closeLoader();
  }
}
