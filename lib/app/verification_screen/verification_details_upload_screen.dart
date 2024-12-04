import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/verification_details_upload_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/utils/dark_theme_provider.dart';

class VerificationDetailsUploadScreen extends StatelessWidget {
  const VerificationDetailsUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<DetailsUploadController>(
        init: DetailsUploadController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
              centerTitle: false,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.chevron_left_outlined,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
              title: Text(
                "${controller.documentModel.value.title}",
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.bold, fontSize: 18),
              ),
              elevation: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upload ${controller.documentModel.value.title} for Verification".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.bold, fontSize: 22),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Please upload a valid ${controller.documentModel.value.title} to verify your identity complete the registration process.".tr,
                            style: TextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Visibility(
                            visible: controller.documentModel.value.frontSide == true ? true : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Front Side of ${controller.documentModel.value.title.toString()}",
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.frontImage.value.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            if (controller.documents.value.status == "rejected") {
                                              buildBottomSheet(context, controller, "front");
                                            }
                                          },
                                          child: SizedBox(
                                            height: Responsive.height(20, context),
                                            width: Responsive.width(90, context),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              child: Constant().hasValidUrl(controller.frontImage.value) == false
                                                  ? Image.file(
                                                      File(controller.frontImage.value),
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(80, context),
                                                      fit: BoxFit.fill,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: controller.frontImage.value.toString(),
                                                      fit: BoxFit.fill,
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(80, context),
                                                      placeholder: (context, url) => Constant.loader(),
                                                      errorWidget: (context, url, error) => Image.network(
                                                          'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                    ),
                                            ),
                                          ),
                                        )
                                      : DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(12),
                                          dashPattern: const [6, 6, 6, 6],
                                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            child: SizedBox(
                                                height: Responsive.height(22, context),
                                                width: Responsive.width(90, context),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/icons/ic_folder.svg',
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Choose a image and upload here".tr,
                                                      style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                          fontFamily: AppThemeData.medium,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "JPEG, PNG".tr,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                                          fontFamily: AppThemeData.regular),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    RoundedButtonFill(
                                                      title: "Brows Image".tr,
                                                      color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                                      width: 30,
                                                      height: 5,
                                                      textColor: AppThemeData.secondary300,
                                                      onPress: () async {
                                                        buildBottomSheet(context, controller, "front");
                                                      },
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: controller.documentModel.value.backSide == true ? true : false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Back side of ${controller.documentModel.value.title.toString()}",
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.backImage.value.isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            if (controller.documents.value.status == "rejected") {
                                              buildBottomSheet(context, controller, "back");
                                            }
                                          },
                                          child: SizedBox(
                                            height: Responsive.height(20, context),
                                            width: Responsive.width(90, context),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              child: Constant().hasValidUrl(controller.backImage.value) == false
                                                  ? Image.file(
                                                      File(controller.backImage.value),
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(80, context),
                                                      fit: BoxFit.fill,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: controller.backImage.value.toString(),
                                                      fit: BoxFit.fill,
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(80, context),
                                                      placeholder: (context, url) => Constant.loader(),
                                                      errorWidget: (context, url, error) => Image.network(
                                                          'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                    ),
                                            ),
                                          ),
                                        )
                                      : DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(12),
                                          dashPattern: const [6, 6, 6, 6],
                                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(12),
                                              ),
                                            ),
                                            child: SizedBox(
                                                height: Responsive.height(22, context),
                                                width: Responsive.width(90, context),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/icons/ic_folder.svg',
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Choose a image and upload here".tr,
                                                      style: TextStyle(
                                                          color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                          fontFamily: AppThemeData.medium,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "JPEG, PNG".tr,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                                          fontFamily: AppThemeData.regular),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    RoundedButtonFill(
                                                      title: "Brows Image".tr,
                                                      color: themeChange.getThem() ? AppThemeData.primary600 : AppThemeData.primary50,
                                                      width: 30,
                                                      height: 5,
                                                      textColor: AppThemeData.secondary300,
                                                      onPress: () async {
                                                        buildBottomSheet(context, controller, "back");
                                                      },
                                                    ),
                                                  ],
                                                )),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Visibility(
                            visible: controller.documents.value.status == "approved" || controller.documents.value.status == "uploaded" ? false : true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: RoundedButtonFill(
                                title: "Upload Document",
                                color: AppThemeData.secondary300,
                                textColor: AppThemeData.grey50,
                                onPress: () {
                                  if (controller.documentModel.value.frontSide == true && controller.frontImage.value.isEmpty) {
                                    ShowToastDialog.showToast("Please upload front side of document.".tr);
                                  } else if (controller.documentModel.value.backSide == true && controller.backImage.value.isEmpty) {
                                    ShowToastDialog.showToast("Please upload back side of document.".tr);
                                  } else {
                                    ShowToastDialog.showLoader("Please wait..".tr);
                                    controller.uploadDocument();
                                  }
                                },
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

  buildBottomSheet(BuildContext context, DetailsUploadController controller, String type) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera, type: type),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery, type: type),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text("Gallery".tr),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
