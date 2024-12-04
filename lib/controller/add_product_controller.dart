import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/AttributesModel.dart';
import 'package:store/models/product_model.dart';
import 'package:store/models/vendor_category_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class AddProductController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> attributesValueController = TextEditingController().obs;

  Rx<TextEditingController> productTitleController = TextEditingController().obs;
  Rx<TextEditingController> productDescriptionController = TextEditingController().obs;
  Rx<TextEditingController> regularPriceController = TextEditingController().obs;
  Rx<TextEditingController> discountedPriceController = TextEditingController().obs;
  Rx<TextEditingController> productQuantityController = TextEditingController().obs;
  Rx<TextEditingController> caloriesController = TextEditingController().obs;
  Rx<TextEditingController> gramsController = TextEditingController().obs;
  Rx<TextEditingController> proteinController = TextEditingController().obs;
  Rx<TextEditingController> fatsController = TextEditingController().obs;

  Rx<ItemAttribute?> itemAttributes = ItemAttribute(attributes: [], variants: []).obs;

  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  Rx<VendorCategoryModel> selectedProductCategory = VendorCategoryModel().obs;

  final myKey1 = GlobalKey<DropdownSearchState<AttributesModel>>();

  Rx<ProductModel> productModel = ProductModel().obs;
  RxList images = <dynamic>[].obs;

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList<AttributesModel> selectedAttributesList = <AttributesModel>[].obs;

  RxList<ProductSpecificationModel> specificationList = <ProductSpecificationModel>[].obs;
  RxList<ProductSpecificationModel> addonsList = <ProductSpecificationModel>[].obs;

  RxString title = "".obs;

  RxBool isPublish = true.obs;
  RxBool isPureVeg = true.obs;
  RxBool isNonVeg = false.obs;

  RxBool takeAway = false.obs;
  RxBool isDiscountedPriceOk = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  addAttribute(String id) {
    ItemAttribute? itemAttribute = itemAttributes.value;
    List<Attributes>? attributesList = itemAttribute!.attributes;
    attributesList!.add(Attributes(attributeId: id, attributeOptions: []));
    itemAttributes.value = itemAttribute;
    update();
  }

  getArgument() async {
    await FireStoreUtils.getVendorCategoryById().then((value) {
      if (value != null) {
        vendorCategoryList.value = value;
      }
    });

    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
      }
    });

    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      productModel.value = argumentData['productModel'];

      for (var element in productModel.value.photos!) {
        images.add(element);
      }

      isPublish.value = productModel.value.publish ?? false;
      productTitleController.value.text = productModel.value.name.toString();
      productDescriptionController.value.text = productModel.value.description.toString();
      regularPriceController.value.text = productModel.value.price.toString();
      discountedPriceController.value.text = productModel.value.disPrice.toString();
      productQuantityController.value.text = productModel.value.quantity.toString();

      caloriesController.value.text = productModel.value.calories.toString();
      gramsController.value.text = productModel.value.grams.toString();
      fatsController.value.text = productModel.value.fats.toString();
      proteinController.value.text = productModel.value.proteins.toString();
      isPureVeg.value = productModel.value.veg ?? true;
      isNonVeg.value = productModel.value.nonveg ?? false;
      takeAway.value = productModel.value.takeawayOption ?? false;
      if (productModel.value.productSpecification != null) {
        productModel.value.productSpecification!.forEach((key, value) {
          specificationList.add(ProductSpecificationModel(lable: key, value: value));
        });
      }

      itemAttributes.value = productModel.value.itemAttribute ?? ItemAttribute();

      if (productModel.value.itemAttribute != null) {
        for (var element in productModel.value.itemAttribute!.attributes!) {
          AttributesModel attributesModel = attributesList.firstWhere((product) => product.id == element.attributeId);
          selectedAttributesList.add(attributesModel);
        }
      }

      for (var element in productModel.value.addOnsTitle!) {
        addonsList.add(ProductSpecificationModel(lable: element, value: productModel.value.addOnsPrice![productModel.value.addOnsTitle!.indexOf(element)]));
      }

      for (var element in vendorCategoryList) {
        if (element.id == productModel.value.categoryID) {
          selectedProductCategory.value = element;
        }
      }
    }

    isLoading.value = false;
  }

  Map<String, dynamic> specification = {};

  saveDetails() async {
    if (selectedProductCategory.value.id == null) {
      ShowToastDialog.showToast("Please Select category");
    } else if (productTitleController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter title");
    } else if (productDescriptionController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter description");
    } else if (regularPriceController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter valid regular price");
    } else if (isDiscountedPriceOk.value == true) {
      ShowToastDialog.showToast("Please enter valid discount price");
    } else if (productQuantityController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter product quantity");
    } else {
      specification.clear();
      for (var element in specificationList) {
        if (element.value!.isNotEmpty && element.lable!.isNotEmpty) {
          specification.addEntries([MapEntry(element.lable.toString(), element.value)]);
        }
      }

      // if (itemAttributes.value!.attributes!.isEmpty || itemAttributes.value!.variants!.isEmpty) {
      //   itemAttributes.value = null;
      // }

      ShowToastDialog.showLoader("Please wait");
      for (int i = 0; i < images.length; i++) {
        if (images[i].runtimeType == XFile) {
          String url = await Constant.uploadUserImageToFireStorage(
            File(images[i].path),
            "profileImage/${FireStoreUtils.getCurrentUid()}",
            File(images[i].path).path.split('/').last,
          );
          images.removeAt(i);
          images.insert(i, url);
        }
      }

      List listAddTitle = [];
      List listAddPrice = [];
      for (var element in addonsList) {
        if (element.value!.isNotEmpty && element.lable!.isNotEmpty) {
          listAddTitle.add(element.lable.toString());
          listAddPrice.add(element.value.toString());
        }
      }

      productModel.value.id = productModel.value.id ?? Constant.getUuid();
      productModel.value.photo = images.isNotEmpty ? images.first : "";
      productModel.value.photos = images;
      productModel.value.price = regularPriceController.value.text.toString();
      productModel.value.disPrice = discountedPriceController.value.text.toString().isEmpty ? "0" : discountedPriceController.value.text.toString();
      productModel.value.quantity = int.parse(productQuantityController.value.text);
      productModel.value.description = productDescriptionController.value.text;
      productModel.value.calories = int.parse(caloriesController.value.text.isEmpty ? "0" : caloriesController.value.text);
      productModel.value.grams = int.parse(gramsController.value.text.isEmpty ? "0" : gramsController.value.text);
      productModel.value.proteins = int.parse(proteinController.value.text.isEmpty ? "0" : proteinController.value.text);
      productModel.value.fats = int.parse(fatsController.value.text.isEmpty ? "0" : fatsController.value.text);
      productModel.value.name = productTitleController.value.text;
      productModel.value.veg = isPureVeg.value;
      productModel.value.nonveg = isNonVeg.value;
      productModel.value.publish = isPublish.value;
      productModel.value.vendorID = Constant.userModel!.vendorID;
      productModel.value.categoryID = selectedProductCategory.value.id.toString();
      productModel.value.itemAttribute = ((itemAttributes.value!.attributes == null || itemAttributes.value!.attributes!.isEmpty) &&
              (itemAttributes.value!.variants == null || itemAttributes.value!.variants!.isEmpty))
          ? null
          : itemAttributes.value;
      productModel.value.addOnsTitle = listAddTitle;
      productModel.value.addOnsPrice = listAddPrice;
      productModel.value.takeawayOption = takeAway.value;
      productModel.value.productSpecification = specification;
      await FireStoreUtils.updateProduct(productModel.value);
      ShowToastDialog.closeLoader();
      Get.back(result: true);
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.clear();
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }

  List<dynamic> getCombination(List<List<dynamic>> listArray) {
    if (listArray.length == 1) {
      return listArray[0];
    } else {
      List<dynamic> result = [];
      var allCasesOfRest = getCombination(listArray.sublist(1));
      for (var i = 0; i < allCasesOfRest.length; i++) {
        for (var j = 0; j < listArray[0].length; j++) {
          result.add(listArray[0][j] + '-' + allCasesOfRest[i]);
        }
      }
      return result;
    }
  }
}
