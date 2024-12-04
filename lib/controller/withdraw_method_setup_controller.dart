import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store/constant/collection_name.dart';
import 'package:store/constant/constant.dart';
import 'package:store/models/payment_model/flutter_wave_model.dart';
import 'package:store/models/payment_model/paypal_model.dart';
import 'package:store/models/payment_model/razorpay_model.dart';
import 'package:store/models/payment_model/stripe_model.dart';
import 'package:store/models/user_model.dart';
import 'package:store/models/withdraw_method_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class WithdrawMethodSetupController extends GetxController {
  Rx<TextEditingController> accountNumberFlutterWave = TextEditingController().obs;
  Rx<TextEditingController> bankCodeFlutterWave = TextEditingController().obs;
  Rx<TextEditingController> emailPaypal = TextEditingController().obs;
  Rx<TextEditingController> accountIdRazorPay = TextEditingController().obs;
  Rx<TextEditingController> accountIdStripe = TextEditingController().obs;

  Rx<UserBankDetails> userBankDetails = UserBankDetails().obs;
  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  RxBool isBankDetailsAdded = false.obs;

  RxBool isLoading = true.obs;
  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getPaymentMethod();
    getPaymentSettings();
    super.onInit();
  }

  getPaymentMethod() async {
    isLoading.value = true;
    accountNumberFlutterWave.value.clear();
    bankCodeFlutterWave.value.clear();
    emailPaypal.value.clear();
    accountIdRazorPay.value.clear();
    accountIdStripe.value.clear();

    await FireStoreUtils.getWithdrawMethod().then(
      (value) {
        if (value != null) {
          withdrawMethodModel.value = value;

          if (withdrawMethodModel.value.flutterWave != null) {
            accountNumberFlutterWave.value.text = withdrawMethodModel.value.flutterWave!.accountNumber.toString();
            bankCodeFlutterWave.value.text = withdrawMethodModel.value.flutterWave!.bankCode.toString();
          }

          if (withdrawMethodModel.value.paypal != null) {
            emailPaypal.value.text = withdrawMethodModel.value.paypal!.email.toString();
          }

          if (withdrawMethodModel.value.razorpay != null) {
            accountIdRazorPay.value.text = withdrawMethodModel.value.razorpay!.accountId.toString();
          }
          if (withdrawMethodModel.value.stripe != null) {
            accountIdStripe.value.text = withdrawMethodModel.value.stripe!.accountId.toString();
          }
        }
      },
    );
    isLoading.value = false;
  }

  getPaymentSettings() async {
    userBankDetails.value = Constant.userModel!.userBankDetails!;
    isBankDetailsAdded.value = userBankDetails.value.accountNumber.isNotEmpty;

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("razorpaySettings").get().then((user) {
      try {
        razorPayModel.value = RazorPayModel.fromJson(user.data() ?? {});
      } catch (e) {
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("paypalSettings").get().then((paypalData) {
      try {
        paypalDataModel.value = PayPalModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("stripeSettings").get().then((paypalData) {
      try {
        stripeSettingData.value = StripeModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("flutterWave").get().then((paypalData) {
      try {
        flutterWaveSettingData.value = FlutterWaveModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });
    isLoading.value = false;
  }
}
