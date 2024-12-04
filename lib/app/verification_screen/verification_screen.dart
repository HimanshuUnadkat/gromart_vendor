import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/controller/verification_controller.dart';
import 'package:store/models/document_model.dart';
import 'package:store/models/driver_document_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/utils/dark_theme_provider.dart';

import 'verification_details_upload_screen.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<VerificationController>(
        init: VerificationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
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
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: controller.isLoading.value
                  ? Constant.loader()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Document Verification".tr,
                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.bold, fontSize: 22),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Upload your ID Proof to complete the verification process and ensure compliance.".tr,
                          style: TextStyle(fontSize: 16, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                          decoration: ShapeDecoration(
                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: ListView.separated(
                              itemCount: controller.documentList.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                DocumentModel documentModel = controller.documentList[index];
                                Documents documents = Documents();

                                var contain = controller.driverDocumentList.where((element) => element.documentId == documentModel.id);
                                if (contain.isNotEmpty) {
                                  documents = controller.driverDocumentList.firstWhere((itemToCheck) => itemToCheck.documentId == documentModel.id);
                                }

                                return InkWell(
                                  onTap: () {
                                    Get.to(const VerificationDetailsUploadScreen(), arguments: {'documentModel': documentModel})!.then(
                                      (value) {
                                        if (value == true) {
                                          controller.getDocument();
                                        }
                                      },
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${documentModel.title}",
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                fontFamily: AppThemeData.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "${documentModel.frontSide == true ? "Front" : ""} ${documentModel.backSide == true ? "And Back" : ""} Photo",
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                fontFamily: AppThemeData.regular,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: Text(
                                          documents.status == "approved"
                                              ? "Verified".tr
                                              : documents.status == "rejected"
                                                  ? "Rejected".tr
                                                  : documents.status == "uploaded"
                                                      ? "Uploaded".tr
                                                      : "Pending".tr,
                                          style: TextStyle(
                                              color: documents.status == "approved"
                                                  ? Colors.green
                                                  : documents.status == "rejected"
                                                      ? Colors.red
                                                      : documents.status == "uploaded"
                                                          ? AppThemeData.primary300
                                                          : Colors.orange,
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 16),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(),
                                );
                              },
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
