import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/add_story_controller.dart';
import 'package:store/models/story_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/network_image_widget.dart';
import 'package:store/widget/video_widget.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddStoryController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Add Story".tr,
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
                          DottedBorder(
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
                                  height: Responsive.height(20, context),
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
                                        "Choose a image for thumbnail".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "JPEG, PNG, JPG, GIF format".tr,
                                        style:
                                            TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Brows Image".tr,
                                        color: themeChange.getThem() ? AppThemeData.secondary600 :AppThemeData.secondary50,
                                        width: 30,
                                        height: 5,
                                        textColor: AppThemeData.secondary300,
                                        onPress: () async {
                                          onCameraClick(context, controller, false);
                                        },
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          controller.thumbnailFile.isEmpty
                              ? const SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        child: controller.thumbnailFile[0].runtimeType == XFile
                                            ? Image.file(
                                                File(controller.thumbnailFile[0].path),
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                              )
                                            : NetworkImageWidget(
                                                imageUrl: controller.thumbnailFile[0],
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                              ),
                                      ),
                                      Positioned(
                                        right: 5,
                                        top: 5,
                                        child: InkWell(
                                          onTap: () {
                                            controller.thumbnailFile.clear();
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: AppThemeData.danger300,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          DottedBorder(
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
                                  height: Responsive.height(20, context),
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
                                        "Choose a story video".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "mp4 format,  less then ${double.parse(controller.videoDuration.toString()).toStringAsFixed(0)} sec.".tr,
                                        style:
                                            TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Brows Video".tr,
                                        color: themeChange.getThem() ? AppThemeData.secondary600 :AppThemeData.secondary50,
                                        width: 30,
                                        height: 5,
                                        textColor: AppThemeData.secondary300,
                                        onPress: () async {
                                          onCameraClick(context, controller, true);
                                        },
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: controller.mediaFiles.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Stack(children: [
                                      VideoWidget(url: controller.mediaFiles[index]),
                                      Positioned(
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              controller.mediaFiles.removeAt(index);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.remove_circle,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ))
                                    ]),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        ShowToastDialog.showLoader("Please wait");
                        await FireStoreUtils.removeStory(Constant.userModel!.vendorID.toString()).then((value) {
                          ShowToastDialog.closeLoader();
                          ShowToastDialog.showToast("Story remove successfully");
                          controller.getStory();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_delete.svg",
                            height: 14,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete Story".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300, fontSize: 16, fontFamily: AppThemeData.medium),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RoundedButtonFill(
                      title: "Save Story".tr,
                      height: 5.5,
                      color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                      textColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      fontSizes: 16,
                      onPress: () async {
                        if (controller.thumbnailFile.isEmpty) {
                          ShowToastDialog.showToast("Please select thumbnail.");
                        } else if (controller.mediaFiles.isEmpty) {
                          ShowToastDialog.showToast("Please Select video");
                        } else {
                          ShowToastDialog.showLoader("Please wait...");

                          String? url;
                          if (controller.thumbnailFile[0] is XFile) {
                            url = await FireStoreUtils.uploadImageOfStory(File(controller.thumbnailFile[0].path), context, getFileExtension(controller.thumbnailFile[0]!.path)!);
                          } else {
                            url = controller.thumbnailFile[0];
                          }

                          List<String> mediaFilesURLs = controller.mediaFiles.whereType<String>().toList().cast<String>();
                          List<File> imagesToUpload = controller.mediaFiles.whereType<File>().toList().cast<File>();

                          if (imagesToUpload.isNotEmpty) {
                            for (int i = 0; i < imagesToUpload.length; i++) {
                              String? url = await FireStoreUtils.uploadVideoStory(
                                imagesToUpload[i],
                                context,
                              );
                              mediaFilesURLs.add(url!);
                            }
                          }

                          StoryModel? storyModel = StoryModel(vendorID: Constant.userModel!.vendorID, videoThumbnail: url, videoUrl: mediaFilesURLs, createdAt: Timestamp.now());
                          await FireStoreUtils.addOrUpdateStory(storyModel).then((value) {
                            ShowToastDialog.closeLoader();
                            ShowToastDialog.showToast("Story upload successfully");
                            Get.back();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  onCameraClick(BuildContext context, AddStoryController controller, bool multipleSelect) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Send Video',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        Visibility(
          visible: multipleSelect,
          child: CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () async {
              Navigator.pop(context);
              XFile? galleryVideo = await controller.imagePicker.pickVideo(source: ImageSource.gallery);
              if (galleryVideo != null) {
                var info = await FlutterVideoInfo().getVideoInfo(galleryVideo.path);
                String rounded = prettyDuration(info!.duration!);

                if (double.parse(rounded).round() <= controller.videoDuration.value) {
                  controller.mediaFiles.add(File(galleryVideo.path));
                } else {
                  ShowToastDialog.showToast("Please select ${controller.videoDuration.value.toString()} second below video.");
                }
              }
            },
            child: const Text('Choose video from gallery'),
          ),
        ),
        Visibility(
          visible: !multipleSelect,
          child: CupertinoActionSheetAction(
            isDefaultAction: false,
            onPressed: () async {
              Navigator.pop(context);
              XFile? galleryVideo = await controller.imagePicker.pickImage(source: ImageSource.gallery);
              if (galleryVideo != null) {
                controller.thumbnailFile.clear();
                controller.thumbnailFile.add(galleryVideo);
              }
            },
            child: const Text('Choose thimbling image / GIF'),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  String prettyDuration(double duration) {
    var seconds = duration / 1000.round();
    return '$seconds';
  }

  String? getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch (e) {
      return null;
    }
  }
}
