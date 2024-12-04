import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store/app/product_rating_view_screen/product_rating_view_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/controller/order_details_controller.dart';
import 'package:store/models/cart_product_model.dart';
import 'package:store/models/order_model.dart';
import 'package:store/models/tax_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/network_image_widget.dart';
import 'package:store/widget/my_separator.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Order Summary".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ${Constant.orderId(orderId: controller.orderModel.value.id.toString())}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 18,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RoundedButtonFill(
                                title: controller.orderModel.value.status.toString().tr,
                                color: Constant.statusColor(status: controller.orderModel.value.status.toString()),
                                width: 32,
                                height: 4.2,
                                radius: 10,
                                textColor: Constant.statusText(status: controller.orderModel.value.status.toString()),
                                onPress: () async {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: NetworkImageWidget(
                                          imageUrl: controller.orderModel.value.author!.profilePictureURL.toString(),
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.orderModel.value.author!.fullName().toString().tr,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 14,
                                                fontFamily: AppThemeData.semiBold,
                                              ),
                                            ),
                                            controller.orderModel.value.takeAway == true
                                                ? Text(
                                                    "Take Away".tr,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.medium,
                                                    ),
                                                  )
                                                : Text(
                                                    controller.orderModel.value.address!.getFullAddress().tr,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                                      fontSize: 12,
                                                      fontFamily: AppThemeData.medium,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.orderModel.value.products!.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      CartProductModel product = controller.orderModel.value.products![index];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${product.quantity}x ${product.name}".tr,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: AppThemeData.semiBold,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    double.parse(product.discountPrice ?? "0.0") <= 0
                                                        ? Constant.amountShow(
                                                            amount: (double.parse(product.price.toString()) * double.parse(product.quantity.toString())).toString())
                                                        : Constant.amountShow(
                                                                amount: (double.parse(product.discountPrice.toString()) * double.parse(product.quantity.toString())).toString())
                                                            .tr,
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppThemeData.semiBold,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Get.to(const ProductRatingViewScreen(), arguments: {"orderModel": controller.orderModel.value, "productId": product.id});
                                                    },
                                                    child: Text(
                                                      "View Ratings".tr,
                                                      style: TextStyle(
                                                        color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                        fontWeight: FontWeight.w500,
                                                        decoration: TextDecoration.underline,
                                                        fontFamily: AppThemeData.semiBold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          product.variantInfo == null || product.variantInfo!.variantOptions!.isEmpty
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Variants",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.semiBold,
                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Wrap(
                                                        spacing: 6.0,
                                                        runSpacing: 6.0,
                                                        children: List.generate(
                                                          product.variantInfo!.variantOptions!.length,
                                                          (i) {
                                                            return Container(
                                                              decoration: ShapeDecoration(
                                                                color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                                child: Text(
                                                                  "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          product.extras == null || product.extras!.isEmpty
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Addons",
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.semiBold,
                                                              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          Constant.amountShow(
                                                              amount: (double.parse(product.extrasPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily: AppThemeData.semiBold,
                                                            color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 6.0,
                                                      children: List.generate(
                                                        product.extras!.length,
                                                        (i) {
                                                          return Container(
                                                            decoration: ShapeDecoration(
                                                              color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                              child: Text(
                                                                product.extras![i].toString(),
                                                                textAlign: TextAlign.start,
                                                                style: TextStyle(
                                                                  fontFamily: AppThemeData.medium,
                                                                  color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.orderModel.value.scheduleTime == null
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Schedule Time".tr,
                                                style: TextStyle(
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: AppThemeData.regular,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.timestampToDateTime(controller.orderModel.value.scheduleTime!).tr,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppThemeData.semiBold,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  controller.orderModel.value.notes == null || controller.orderModel.value.notes!.isEmpty
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return viewRemarkDialog(controller, themeChange, controller.orderModel.value);
                                              },
                                            );
                                          },
                                          child: Text(
                                            "View Remarks",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              decoration: TextDecoration.underline,
                                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Item totals",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.subTotal.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Coupon Discount",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "- (${Constant.amountShow(amount: controller.orderModel.value.discount.toString())})",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  controller.orderModel.value.specialDiscount != null &&  controller.orderModel.value.specialDiscount!['special_discount'] != null
                                      ? Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Special Discount",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "- (${Constant.amountShow(amount: controller.specialDiscount.value.toString())})",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                      : const SizedBox(),

                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    itemCount: controller.orderModel.value.taxSetting!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      TaxModel taxModel = controller.orderModel.value.taxSetting![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                  amount: Constant.calculateTax(
                                                          amount: (controller.subTotal.value -
                                                                  double.parse(controller.orderModel.value.discount.toString()) -
                                                                  controller.specialDiscount.value)
                                                              .toString(),
                                                          taxModel: taxModel)
                                                      .toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "To Pay",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.totalAmount.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: RoundedButtonFill(
                                      title: "Print Invoice".tr,
                                      color: AppThemeData.danger300,
                                      textColor: AppThemeData.grey50,
                                      height: 5,
                                      onPress: () async {
                                        controller.printTicket();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Admin Commissions".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 14, fontFamily: AppThemeData.medium),
                                ),
                              ),
                              Text(
                                Constant.amountShow(amount: controller.adminComm.value.toString()).tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300, fontSize: 14, fontFamily: AppThemeData.semiBold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.warning600 : AppThemeData.warning50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text(
                                "Note : Admin commission will be debited from your wallet balance. \n \n Admin commission will apply on order Amount minus Discount & Special Discount (if applicable)."
                                    .tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.warning200 : AppThemeData.warning400, fontSize: 14, fontFamily: AppThemeData.medium),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  viewRemarkDialog(OrderDetailsController controller, themeChange, OrderModel orderModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  orderModel.notes.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                    fontSize: 18,
                  ),
                ),
              ),
              RoundedButtonFill(
                title: "Cancel".tr,
                color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                onPress: () async {
                  Get.back();
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
