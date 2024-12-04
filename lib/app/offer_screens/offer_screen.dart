import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store/app/offer_screens/add_edit_offer_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/offer_controller.dart';
import 'package:store/models/coupon_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/network_image_widget.dart';

import '../../widget/my_separator.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OfferController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Offers".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : controller.offerList.isEmpty
                      ? Constant.showEmptyView(message: "No Offer found")
                      : ListView.builder(
                          itemCount: controller.offerList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            CouponModel couponModel = controller.offerList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          NetworkImageWidget(
                                            imageUrl: couponModel.image.toString(),
                                            height: 72,
                                            width: 72,
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                DottedBorder(
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(10),
                                                  dashPattern: const [6, 6, 6, 6],
                                                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                      borderRadius: const BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                                                      child: Text(
                                                        "${couponModel.code}".tr,
                                                        style: TextStyle(
                                                            color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                                            fontSize: 18,
                                                            fontFamily: AppThemeData.medium),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  (couponModel.discountType == "Fix Price".tr
                                                          ? "${Constant.amountShow(amount: couponModel.discount)} Off"
                                                          : "${couponModel.discount} % Off")
                                                      .tr,
                                                  style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                      fontSize: 14,
                                                      fontFamily: AppThemeData.medium),
                                                )
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(const AddEditOfferScreen(), arguments: {"couponModel": couponModel})!.then(
                                                (value) {
                                                  if (value == true) {
                                                    controller.getOffers();
                                                  }
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                                                  borderRadius: BorderRadius.circular(120),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset("assets/icons/ic_edit_coupon.svg"),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              ShowToastDialog.showLoader("Please wait");
                                              await FireStoreUtils.deleteCoupon(couponModel).then(
                                                (value) {
                                                  controller.getOffers();
                                                  ShowToastDialog.closeLoader();
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                                                  borderRadius: BorderRadius.circular(120),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SvgPicture.asset("assets/icons/ic_delete-one.svg"),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                      ),
                                      Text(
                                        "This offer is expire on ${Constant.timestampToDateTime(couponModel.expiresAt!)}".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600, fontSize: 14, fontFamily: AppThemeData.medium),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: AppThemeData.secondary300,
              onPressed: () {
                Get.to(const AddEditOfferScreen())!.then(
                  (value) {
                    if (value == true) {
                      controller.getOffers();
                    }
                  },
                );
              },
              child: const Icon(
                Icons.add,
                color: AppThemeData.grey50,
              ),
            ),
          );
        });
  }
}
