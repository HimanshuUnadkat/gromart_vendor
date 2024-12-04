import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store/app/Home_screen/order_details_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/wallet_controller.dart';
import 'package:store/models/wallet_transaction_model.dart';
import 'package:store/models/withdrawal_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/themes/text_field_widget.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/widget/my_separator.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: WalletController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Wallet".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Container(
                          width: Responsive.width(100, context),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            image: DecorationImage(
                              image: AssetImage("assets/images/wallet.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Column(
                              children: [
                                Text(
                                  "My Wallet".tr,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey900,
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: AppThemeData.regular,
                                  ),
                                ),
                                Text(
                                  Constant.amountShow(amount: controller.userModel.value.walletAmount.toString()),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey900,
                                    fontSize: 40,
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: AppThemeData.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                (Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false) ||
                                        (controller.userModel.value.vendorID == null || controller.userModel.value.vendorID!.isEmpty)
                                    ? const SizedBox()
                                    : RoundedButtonFill(
                                        title: "Withdraw".tr,
                                        width: 24,
                                        height: 5,
                                        color: AppThemeData.secondary300,
                                        textColor: AppThemeData.grey50,
                                        onPress: () {
                                          if ((Constant.userModel!.userBankDetails != null && Constant.userModel!.userBankDetails!.accountNumber.isNotEmpty) ||
                                              controller.withdrawMethodModel.value.id != null) {
                                            withdrawalCardBottomSheet(context, controller);
                                          } else {
                                            ShowToastDialog.showToast("Please setup payment method");
                                          }
                                        },
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TabBar(
                                  onTap: (value) {
                                    controller.selectedTabIndex.value = value;
                                  },
                                  padding: EdgeInsets.zero,
                                  labelStyle: const TextStyle(fontFamily: AppThemeData.semiBold),
                                  labelColor: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                  unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.medium),
                                  unselectedLabelColor: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                  indicatorColor: AppThemeData.secondary300,
                                  tabs: [
                                    Tab(
                                      text: "Transaction History".tr,
                                    ),
                                    Tab(
                                      text: "Withdrawal History".tr,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    controller.walletTransactionList.isEmpty
                                        ? Constant.showEmptyView(message: "Transaction history not found")
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ListView.separated(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: controller.walletTransactionList.length,
                                                  itemBuilder: (context, index) {
                                                    WalletTransactionModel walletTractionModel = controller.walletTransactionList[index];
                                                    return transactionCard(controller, themeChange, walletTractionModel);
                                                  },
                                                  separatorBuilder: (BuildContext context, int index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                      child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                    controller.withdrawalList.isEmpty
                                        ? Constant.showEmptyView(message: "Transaction history not found")
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ListView.separated(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: controller.withdrawalList.length,
                                                  itemBuilder: (context, index) {
                                                    WithdrawalModel walletTractionModel = controller.withdrawalList[index];
                                                    return transactionCardWithdrawal(controller, themeChange, walletTractionModel);
                                                  },
                                                  separatorBuilder: (BuildContext context, int index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                                      child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }

  withdrawalCardBottomSheet(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
              heightFactor: 0.8,
              child: StatefulBuilder(builder: (context1, setState) {
                final themeChange = Provider.of<DarkThemeProvider>(context);
                return Obx(
                  () => Scaffold(
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Withdrawal".tr,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 18, fontFamily: AppThemeData.semiBold),
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: const Icon(Icons.close)),
                                ],
                              ),
                            ),
                            TextFieldWidget(
                              title: 'Withdrawal amount'.tr,
                              controller: controller.amountTextFieldController.value,
                              hintText: 'Enter withdrawal amount'.tr,
                              textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                              ],
                              prefix: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Text(
                                  "${Constant.currencyModel!.symbol}".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                ),
                              ),
                            ),
                            TextFieldWidget(
                              title: 'Notes'.tr,
                              controller: controller.noteTextFieldController.value,
                              hintText: 'Add Notes'.tr,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Select Withdraw Method".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 16, fontFamily: AppThemeData.medium),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)), color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Column(
                                  children: [
                                    Constant.userModel!.userBankDetails == null || Constant.userModel!.userBankDetails!.accountNumber.isEmpty
                                        ? const SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              controller.selectedValue.value = 0;
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset("assets/icons/ic_building_four.svg"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Bank Transfer".tr,
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.medium),
                                                  ),
                                                ),
                                                Radio(
                                                  value: 0,
                                                  groupValue: controller.selectedValue.value,
                                                  activeColor: AppThemeData.secondary300,
                                                  onChanged: (value) {
                                                    controller.selectedValue.value = value!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.withdrawMethodModel.value.flutterWave == null || (controller.flutterWaveSettingData.value.isWithdrawEnabled == false)
                                        ? const SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              controller.selectedValue.value = 1;
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Image.asset("assets/images/flutterwave.png"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Flutter wave".tr,
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.medium),
                                                  ),
                                                ),
                                                Radio(
                                                  value: 1,
                                                  groupValue: controller.selectedValue.value,
                                                  activeColor: AppThemeData.secondary300,
                                                  onChanged: (value) {
                                                    controller.selectedValue.value = value!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.withdrawMethodModel.value.paypal == null || (controller.paypalDataModel.value.isWithdrawEnabled == false)
                                        ? const SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              controller.selectedValue.value = 2;
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Image.asset("assets/images/paypal.png"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "PayPal".tr,
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.medium),
                                                  ),
                                                ),
                                                Radio(
                                                  value: 2,
                                                  groupValue: controller.selectedValue.value,
                                                  activeColor: AppThemeData.secondary300,
                                                  onChanged: (value) {
                                                    controller.selectedValue.value = value!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.withdrawMethodModel.value.razorpay == null || (controller.razorPayModel.value.isWithdrawEnabled == false)
                                        ? const SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              controller.selectedValue.value = 3;
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Image.asset("assets/images/razorpay.png"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "RazorPay".tr,
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.medium),
                                                  ),
                                                ),
                                                Radio(
                                                  value: 3,
                                                  groupValue: controller.selectedValue.value,
                                                  activeColor: AppThemeData.secondary300,
                                                  onChanged: (value) {
                                                    controller.selectedValue.value = value!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.withdrawMethodModel.value.stripe == null || (controller.stripeSettingData.value.isWithdrawEnabled == false)
                                        ? const SizedBox()
                                        : InkWell(
                                            onTap: () {
                                              controller.selectedValue.value = 4;
                                            },
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: Image.asset("assets/images/stripe.png"),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Stripe".tr,
                                                    style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.medium),
                                                  ),
                                                ),
                                                Radio(
                                                  value: 4,
                                                  groupValue: controller.selectedValue.value,
                                                  activeColor: AppThemeData.secondary300,
                                                  onChanged: (value) {
                                                    controller.selectedValue.value = value!;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    bottomNavigationBar: Container(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RoundedButtonFill(
                          title: "Withdraw".tr,
                          height: 5.5,
                          color: AppThemeData.primary300,
                          textColor: AppThemeData.grey50,
                          fontSizes: 16,
                          onPress: () async {
                            if (controller.amountTextFieldController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter amount");
                            } else if (controller.noteTextFieldController.value.text.isEmpty) {
                              ShowToastDialog.showToast("Please enter note");
                            } else if (double.parse(controller.userModel.value.walletAmount.toString()) <= 0) {
                              ShowToastDialog.showToast("You are not able to place Withdraw request due to insufficient wallet amount");
                            } else {
                              WithdrawalModel withdrawHistory = WithdrawalModel(
                                amount: controller.amountTextFieldController.value.text,
                                vendorID: controller.userModel.value.vendorID,
                                paymentStatus: "Pending",
                                paidDate: Timestamp.now(),
                                id: Constant.getUuid(),
                                note: controller.noteTextFieldController.value.text,
                                withdrawMethod: controller.selectedValue.value == 0
                                    ? "bank"
                                    : controller.selectedValue.value == 1
                                        ? "flutterwave"
                                        : controller.selectedValue.value == 2
                                            ? "paypal"
                                            : controller.selectedValue.value == 3
                                                ? "razorpay"
                                                : "stripe",
                              );
                              await FireStoreUtils.withdrawWalletAmount(withdrawHistory);
                              await FireStoreUtils.updateUserWallet(amount: "-${controller.amountTextFieldController.value.text}", userId: FireStoreUtils.getCurrentUid())
                                  .then((value) {
                                Get.back();
                                FireStoreUtils.sendPayoutMail(amount: controller.amountTextFieldController.value.text, payoutrequestid: withdrawHistory.id.toString());
                                controller.getWalletTransaction();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ));
  }

  transactionCardWithdrawal(WalletController controller, themeChange, WithdrawalModel transactionModel) {
    return InkWell(
      onTap: () async {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  "assets/icons/ic_debit.svg",
                  height: 16,
                  width: 16,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transactionModel.note.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w600,
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                              ),
                            ),
                            Text(
                              "(${transactionModel.withdrawMethod!.capitalizeString()})",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w600,
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "-${Constant.amountShow(amount: transactionModel.amount!.isEmpty ? "0.0" : transactionModel.amount.toString())}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: AppThemeData.medium,
                          color: AppThemeData.danger300,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transactionModel.paymentStatus.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            color: transactionModel.paymentStatus == "Success"
                                ? AppThemeData.success400
                                : transactionModel.paymentStatus == "Pending"
                                    ? AppThemeData.primary300
                                    : AppThemeData.danger300,
                          ),
                        ),
                      ),
                      Text(
                        Constant.timestampToDateTime(transactionModel.paidDate!),
                        style: TextStyle(
                            fontSize: 12, fontFamily: AppThemeData.medium, fontWeight: FontWeight.w500, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  transactionCard(WalletController controller, themeChange, WalletTransactionModel transactionModel) {
    return InkWell(
      onTap: () async {
        await FireStoreUtils.getOrderByOrderId(transactionModel.orderId.toString()).then(
          (value) {
            if (value != null) {
              Get.to(const OrderDetailsScreen(), arguments: {"orderModel": value});
            }
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: transactionModel.isTopup == false
                    ? SvgPicture.asset(
                        "assets/icons/ic_debit.svg",
                        height: 16,
                        width: 16,
                      )
                    : SvgPicture.asset(
                        "assets/icons/ic_credit.svg",
                        height: 16,
                        width: 16,
                      ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transactionModel.note.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                          ),
                        ),
                      ),
                      Text(
                        transactionModel.isTopup == false
                            ? "-${Constant.amountShow(amount: transactionModel.amount.toString())}"
                            : Constant.amountShow(amount: transactionModel.amount.toString()),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppThemeData.medium,
                          color: transactionModel.isTopup == true ? AppThemeData.success400 : AppThemeData.danger300,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    Constant.timestampToDateTime(transactionModel.date!),
                    style: TextStyle(
                        fontSize: 12, fontFamily: AppThemeData.medium, fontWeight: FontWeight.w500, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
