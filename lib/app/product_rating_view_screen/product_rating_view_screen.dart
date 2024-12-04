import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/controller/product_rating_view_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/widget/my_separator.dart';

class ProductRatingViewScreen extends StatelessWidget {
  const ProductRatingViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ProductRatingViewController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "View Review".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          width: Responsive.width(100, context),
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
                                Text(
                                  "Rate for".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.medium),
                                ),
                                Text(
                                  "${controller.productModel.value.name}".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 18, fontFamily: AppThemeData.semiBold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                RatingBar.builder(
                                  ignoreGestures: true,
                                  initialRating: double.parse(controller.ratingModel.value.rating == null ? "0.0" : controller.ratingModel.value.rating.toString()),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 26,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: AppThemeData.warning300,
                                  ),
                                  onRatingUpdate: (double rate) {
                                    // print(ratings);
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ListView.builder(
                                  itemCount: controller.reviewAttributeList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              controller.reviewAttributeList[index].title.toString(),
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                                fontFamily: AppThemeData.semiBold,
                                              ),
                                            ),
                                          ),
                                          RatingBar.builder(
                                            ignoreGestures: true,
                                            initialRating: controller.ratingModel.value.id == null
                                                ? 0.0
                                                : controller.ratingModel.value.reviewAttributes![controller.reviewAttributeList[index].id] ?? 0.0,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            itemCount: 5,
                                            itemSize: 18,
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: AppThemeData.warning300,
                                            ),
                                            onRatingUpdate: (double rate) {
                                              // print(ratings);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                ),
                                controller.ratingModel.value.comment == null || controller.ratingModel.value.comment!.isEmpty
                                    ? const SizedBox()
                                    : Text(
                                        "${controller.ratingModel.value.comment}".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.medium),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}
