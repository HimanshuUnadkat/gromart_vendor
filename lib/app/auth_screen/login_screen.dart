import 'dart:io';

import 'package:store/app/auth_screen/phone_number_screen.dart';
import 'package:store/app/auth_screen/signup_screen.dart';
import 'package:store/app/forgot_password_screen/forgot_password_screen.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/login_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/themes/text_field_widget.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                    ),
                    Text(
                      "Log in to continue managing your Store’s orders and reservations seamlessly.".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TextFieldWidget(
                      title: 'Email'.tr,
                      controller: controller.emailEditingController.value,
                      hintText: 'Enter email address'.tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_mail.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    TextFieldWidget(
                      title: 'Password'.tr,
                      controller: controller.passwordEditingController.value,
                      hintText: 'Enter Password'.tr,
                      obscureText: controller.passwordVisible.value,
                      prefix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          "assets/icons/ic_lock.svg",
                          colorFilter: ColorFilter.mode(
                            themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      suffix: Padding(
                        padding: const EdgeInsets.all(12),
                        child: InkWell(
                            onTap: () {
                              controller.passwordVisible.value = !controller.passwordVisible.value;
                            },
                            child: controller.passwordVisible.value
                                ? SvgPicture.asset(
                              "assets/icons/ic_password_show.svg",
                              colorFilter: ColorFilter.mode(
                                themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                BlendMode.srcIn,
                              ),
                            )
                                : SvgPicture.asset(
                              "assets/icons/ic_password_close.svg",
                              colorFilter: ColorFilter.mode(
                                themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                BlendMode.srcIn,
                              ),
                            )),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Get.to(const ForgotPasswordScreen());
                        },
                        child: Text(
                          "Forgot Password".tr,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: AppThemeData.secondary300,
                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                              fontSize: 14,
                              fontFamily: AppThemeData.regular),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RoundedButtonFill(
                      title: "Login".tr,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      onPress: () async {
                        if (controller.emailEditingController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter valid email");
                        } else if (controller.passwordEditingController.value.text.isEmpty) {
                          ShowToastDialog.showToast("Please enter valid password");
                        } else {
                          controller.loginWithEmailAndPassword();
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Text(
                              "or".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                fontSize: 16,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    RoundedButtonFill(
                      title: "Log in with Mobile Number".tr,
                      color: themeChange.getThem() ? AppThemeData.grey700 :AppThemeData.grey200,
                      textColor: themeChange.getThem() ?AppThemeData.grey50:AppThemeData.grey900,
                      onPress: () async {
                        Get.to(const PhoneNumberScreen());
                      },
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: Platform.isAndroid ? 10 : 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Didn’t have an account?'.tr,
                            style:  TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontFamily: AppThemeData.medium,
                              fontWeight: FontWeight.w500,
                            )),
                        const WidgetSpan(
                            child: SizedBox(
                          width: 10,
                        )),
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(const SignupScreen());
                              },
                            text: 'Sign up'.tr,
                            style:  TextStyle(
                                color: AppThemeData.secondary300,
                                fontFamily: AppThemeData.bold,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppThemeData.secondary300)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
