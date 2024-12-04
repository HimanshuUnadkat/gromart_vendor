import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:store/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:store/app/add_story_screen/add_story_screen.dart';
import 'package:store/app/auth_screen/login_screen.dart';
import 'package:store/app/change%20langauge/change_language_screen.dart';
import 'package:store/app/edit_profile_screen/edit_profile_screen.dart';
import 'package:store/app/offer_screens/offer_screen.dart';
import 'package:store/app/special_discount_screen/special_discount_screen.dart';
import 'package:store/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:store/app/verification_screen/verification_screen.dart';
import 'package:store/app/withdraw_method_setup_screens/withdraw_method_setup_screen.dart';
import 'package:store/app/working_hours_screen/working_hours_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/dash_board_controller.dart';
import 'package:store/controller/profile_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/custom_dialog_box.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/network_image_widget.dart';
import 'package:store/utils/preferences.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProfileController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Store Profile".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: NetworkImageWidget(
                                    imageUrl: controller.userModel.value.profilePictureURL.toString(),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${controller.userModel.value.fullName()}",
                                        style: TextStyle(
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        "${controller.userModel.value.email}",
                                        style: TextStyle(
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                            fontFamily: AppThemeData.regular,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Edit Profile".tr,
                                        color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                        textColor: AppThemeData.secondary300,
                                        width: 24,
                                        height: 4,
                                        onPress: () async {
                                          Get.to(const EditProfileScreen())!.then(
                                            (value) {
                                              if (value == true) {
                                                controller.getUserProfile();
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            "Store Information",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  (Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false) ||
                                          (controller.userModel.value.vendorID == null || controller.userModel.value.vendorID!.isEmpty)
                                      ? const SizedBox()
                                      : Constant.storyEnable == false
                                          ? const SizedBox()
                                          : cardDecoration(
                                              themeChange,
                                              controller,
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: ShapeDecoration(
                                                  color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/ic_story.svg",
                                                    colorFilter: ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                                  ),
                                                ),
                                              ),
                                              "Add Story",
                                              () {
                                                Get.to(const AddStoryScreen());
                                              },
                                            ),
                                  Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false
                                      ? const SizedBox()
                                      : cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                "assets/icons/ic_building_two.svg",
                                                colorFilter: ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          "Store Information's",
                                          () {
                                            Get.to(const AddRestaurantScreen());
                                          },
                                        ),
                                  (Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false) ||
                                          (controller.userModel.value.vendorID == null || controller.userModel.value.vendorID!.isEmpty)
                                      ? const SizedBox()
                                      : cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: SvgPicture.asset(
                                                "assets/icons/ic_manage_product.svg",
                                                colorFilter: ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          "Manage Products",
                                          () {
                                            DashBoardController dashBoardController = Get.find<DashBoardController>();
                                            dashBoardController.selectedIndex.value = 1;
                                          },
                                        ),
                                  (Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false) ||
                                          (controller.userModel.value.vendorID == null || controller.userModel.value.vendorID!.isEmpty)
                                      ? const SizedBox()
                                      : cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                "assets/icons/ic_alarm-clock.svg",
                                                colorFilter: ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                          "Working Hours",
                                          () {
                                            Get.to(const WorkingHoursScreen());
                                          },
                                        ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_wallet.svg",
                                          colorFilter: ColorFilter.mode(AppThemeData.secondary300, BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                    "Withdraw Method",
                                    () {
                                      Get.to(const WithdrawMethodSetupScreen());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          (Constant.isRestaurantVerification == true && controller.userModel.value.isDocumentVerify == false) ||
                                  (controller.userModel.value.vendorID == null || controller.userModel.value.vendorID!.isEmpty)
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Offers & Discounts",
                                      style: TextStyle(
                                        color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Column(
                                          children: [
                                            cardDecoration(
                                              themeChange,
                                              controller,
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: ShapeDecoration(
                                                  color: themeChange.getThem() ? AppThemeData.success600 : AppThemeData.success50,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(120),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: SvgPicture.asset("assets/icons/ic_gift_box.svg"),
                                                ),
                                              ),
                                              "Offers",
                                              () {
                                                Get.to(const OfferScreen());
                                              },
                                            ),
                                            Constant.specialDiscountOfferEnable == false
                                                ? const SizedBox()
                                                : cardDecoration(
                                                    themeChange,
                                                    controller,
                                                    Container(
                                                      width: 44,
                                                      height: 44,
                                                      decoration: ShapeDecoration(
                                                        color: themeChange.getThem() ? AppThemeData.success600 : AppThemeData.success50,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(120),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10),
                                                        child: SvgPicture.asset(
                                                          "assets/icons/ic_coupon.svg",
                                                        ),
                                                      ),
                                                    ),
                                                    "Special Discounts",
                                                    () {
                                                      Get.to(const SpecialDiscountScreen());
                                                    },
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Preferences",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.warning600 : AppThemeData.warning50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset("assets/icons/ic_language.svg"),
                                      ),
                                    ),
                                    "Change Language",
                                    () {
                                      Get.to(const ChangeLanguageScreen());
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.warning600 : AppThemeData.warning50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_darkmode.svg",
                                        ),
                                      ),
                                    ),
                                    "Dark Mode",
                                    () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Social",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.info600 : AppThemeData.info50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset("assets/icons/ic_share.svg"),
                                      ),
                                    ),
                                    "Share app",
                                    () {
                                      Share.share(
                                          'Check out Foodie, your ultimate food delivery application! \n\nGoogle Play: ${Constant.googlePlayLink} \n\nApp Store: ${Constant.appStoreLink}',
                                          subject: 'Look what I made!');
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.info600 : AppThemeData.info50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_rate.svg",
                                        ),
                                      ),
                                    ),
                                    "Rate the app",
                                    () {
                                      final InAppReview inAppReview = InAppReview.instance;
                                      inAppReview.requestReview();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Legal",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset("assets/icons/ic_documention.svg"),
                                      ),
                                    ),
                                    "Document Verifications",
                                    () {
                                      Get.to(const VerificationScreen());
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_terms_condition.svg",
                                        ),
                                      ),
                                    ),
                                    "Terms and Conditions",
                                    () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "termAndCondition",
                                      ));
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_privacyPolicy.svg",
                                        ),
                                      ),
                                    ),
                                    "Privacy Policy",
                                    () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "privacy",
                                      ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Column(
                                children: [
                                  cardDecoration(themeChange, controller, SvgPicture.asset("assets/icons/ic_logout.svg"), "Log out", () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Log out".tr,
                                            descriptions: "Are you sure you want to log out? You will need to enter your credentials to log back in.".tr,
                                            positiveString: "Log out".tr,
                                            negativeString: "Cancel".tr,
                                            positiveClick: () async {
                                              await FirebaseAuth.instance.signOut();
                                              Get.offAll(const LoginScreen());
                                            },
                                            negativeClick: () {
                                              Get.back();
                                            },
                                            img: Image.asset(
                                              'assets/images/ic_logout.gif',
                                              height: 50,
                                              width: 50,
                                            ),
                                          );
                                        });
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        title: "Delete Account".tr,
                                        descriptions: "Are you sure you want to delete your account? This action is irreversible and will permanently remove all your data.".tr,
                                        positiveString: "Delete".tr,
                                        negativeString: "Cancel".tr,
                                        positiveClick: () async {
                                          ShowToastDialog.showLoader("Please wait".tr);
                                          await FireStoreUtils.deleteUser().then((value) {
                                            ShowToastDialog.closeLoader();
                                            if (value == true) {
                                              ShowToastDialog.showToast("Account deleted successfully".tr);
                                              Get.offAll(const LoginScreen());
                                            } else {
                                              ShowToastDialog.showToast("Contact Administrator".tr);
                                            }
                                          });
                                        },
                                        negativeClick: () {
                                          Get.back();
                                        },
                                        img: Image.asset(
                                          'assets/icons/delete_dialog.gif',
                                          height: 50,
                                          width: 50,
                                        ),
                                      );
                                    });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_delete.svg"),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Delete Account",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 16,
                                      color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "V : ${Constant.appVersion}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppThemeData.medium,
                                fontSize: 14,
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  cardDecoration(themeChange, ProfileController controller, Widget image, String title, Function()? onPress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onPress!();
        },
        child: Row(
          children: [
            image,
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: title == "Log out"
                      ? AppThemeData.danger300
                      : themeChange.getThem()
                          ? AppThemeData.grey100
                          : AppThemeData.grey800,
                ),
              ),
            ),
            title == "Dark Mode"
                ? Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: controller.isDarkModeSwitch.value,
                      activeColor: AppThemeData.primary300,
                      onChanged: (value) {
                        controller.isDarkModeSwitch.value = value;
                        if (controller.isDarkModeSwitch.value == true) {
                          Preferences.setString(Preferences.themKey, "Dark");
                          themeChange.darkTheme = 0;
                        } else if (controller.isDarkMode.value == "Light") {
                          Preferences.setString(Preferences.themKey, "Light");
                          themeChange.darkTheme = 1;
                        } else {
                          Preferences.setString(Preferences.themKey, "");
                          themeChange.darkTheme = 2;
                        }
                      },
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}
