import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/document_model.dart';
import 'package:store/models/driver_document_model.dart';
import 'package:store/utils/fire_store_utils.dart';
class DetailsUploadController extends GetxController {
  Rx<DocumentModel> documentModel = DocumentModel().obs;

  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxString frontImage = "".obs;
  RxString backImage = "".obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      documentModel.value = argumentData['documentModel'];
    }
    getDocument();
    update();
  }

  Rx<Documents> documents = Documents().obs;

  getDocument() async {
    await FireStoreUtils.getDocumentOfDriver().then((value) {
      isLoading.value = false;
      if (value != null) {
        var contain = value.documents!.where((element) => element.documentId == documentModel.value.id);
        if (contain.isNotEmpty) {
          documents.value = value.documents!.firstWhere((itemToCheck) => itemToCheck.documentId == documentModel.value.id);
          frontImage.value = documents.value.frontImage!;
          backImage.value = documents.value.backImage!;
        }
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source, required String type}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();

      if (type == "front") {
        frontImage.value = image.path;
      } else {
        backImage.value = image.path;
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }


  uploadDocument() async {
    String frontImageFileName = File(frontImage.value).path.split('/').last;
    String backImageFileName = File(backImage.value).path.split('/').last;

    if(frontImage.value.isNotEmpty && Constant().hasValidUrl(frontImage.value) == false){
      frontImage.value = await Constant.uploadUserImageToFireStorage(File(frontImage.value), "driverDocument/${FireStoreUtils.getCurrentUid()}", frontImageFileName);
    }

    if(backImage.value.isNotEmpty && Constant().hasValidUrl(backImage.value) == false){
      backImage.value = await Constant.uploadUserImageToFireStorage(File(backImage.value), "driverDocument/${FireStoreUtils.getCurrentUid()}", backImageFileName);
    }
    documents.value.frontImage = frontImage.value;
    documents.value.backImage = backImage.value;
    documents.value.documentId = documentModel.value.id;
    documents.value.status = "uploaded";


    await FireStoreUtils.uploadDriverDocument(documents.value).then((value) {
      if (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Document upload successfully");

        Get.back(result: true);
      }
    });
  }
}
