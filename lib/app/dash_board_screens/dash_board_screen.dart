import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/dash_board_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DashBoardController(),
        builder: (controller) {
          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvoked: (didPop) {
              final now = DateTime.now();
              if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                controller.currentBackPressTime = now;
                controller.canPopNow.value = false;
                ShowToastDialog.showToast("Double press to exit");
                return;
              } else {
                controller.canPopNow.value = true;
              }
            },
            // onPopInvokedWithResult: (didPop, dynamic) {
            //   final now = DateTime.now();
            //   if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
            //     controller.currentBackPressTime = now;
            //     controller.canPopNow.value = false;
            //     ShowToastDialog.showToast("Double press to exit");
            //     return;
            //   } else {
            //     controller.canPopNow.value = true;
            //   }
            // },
            child: Scaffold(
              body: controller.pageList[controller.selectedIndex.value],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                showSelectedLabels: true,
                selectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.bold),
                currentIndex: controller.selectedIndex.value,
                backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                selectedItemColor: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                unselectedItemColor: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                onTap: (int index) {
                  audioPlayer.stop();
                  controller.selectedIndex.value = index;
                },
                items: [
                  navigationBarItem(
                    themeChange,
                    index: 0,
                    assetIcon: "assets/icons/ic_home.svg",
                    label: 'Home'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 1,
                    assetIcon: "assets/icons/ic_knife_fork.svg",
                    label: 'Products'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 2,
                    assetIcon: "assets/icons/ic_wallet.svg",
                    label: 'Wallet'.tr,
                    controller: controller,
                  ),
                  navigationBarItem(
                    themeChange,
                    index: 3,
                    assetIcon: "assets/icons/ic_profile.svg",
                    label: 'Profile'.tr,
                    controller: controller,
                  ),
                ],
              ),
            ),
          );
        });
  }

  BottomNavigationBarItem navigationBarItem(themeChange, {required int index, required String label, required String assetIcon, required DashBoardController controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          assetIcon,
          height: 22,
          width: 22,
          color: controller.selectedIndex.value == index
              ? themeChange.getThem()
                  ? AppThemeData.secondary300
                  : AppThemeData.secondary300
              : themeChange.getThem()
                  ? AppThemeData.grey300
                  : AppThemeData.grey600,
        ),
      ),
      label: label,
    );
  }
}
