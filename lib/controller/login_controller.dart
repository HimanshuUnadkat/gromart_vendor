import 'package:store/app/auth_screen/login_screen.dart';
import 'package:store/app/dash_board_screens/dash_board_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/user_model.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  loginWithEmailAndPassword() async {
    ShowToastDialog.showLoader("Please wait.");
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.value.text.toLowerCase().trim(),
        password: passwordEditingController.value.text.trim(),
      );
      UserModel? userModel = await FireStoreUtils.getUserProfile(credential.user!.uid);
      if(userModel != null){
        if (userModel!.role == Constant.userRoleVendor) {
          if (userModel.active == true) {
            userModel.fcmToken = await NotificationService.getToken();
            await FireStoreUtils.updateUser(userModel);
            Get.offAll(const DashBoardScreen());
          } else {
            ShowToastDialog.showToast("This user is disable please contact to administrator");
            await FirebaseAuth.instance.signOut();
            Get.offAll(const LoginScreen());
          }
        } else {
          await FirebaseAuth.instance.signOut();
          Get.offAll(const LoginScreen());
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'user-not-found') {
        ShowToastDialog.showToast("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        ShowToastDialog.showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        ShowToastDialog.showToast("Invalid Email.");
      } else {
        ShowToastDialog.showToast("${e.message}");
      }
    }
    ShowToastDialog.closeLoader();
  }
}
