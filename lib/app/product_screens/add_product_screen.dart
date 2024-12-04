import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/add_product_controller.dart';
import 'package:store/models/AttributesModel.dart';
import 'package:store/models/product_model.dart';
import 'package:store/models/vendor_category_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/themes/text_field_widget.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/fire_store_utils.dart';
import 'package:store/utils/network_image_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddProductController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppThemeData.secondary300,
                    centerTitle: false,
                    iconTheme: const IconThemeData(color: AppThemeData.grey50),
                    title: Text(
                      controller.productModel.value.id == null ? "Add Product" : "Edit product".tr,
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.danger600 : AppThemeData.danger50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Product prices include a 15% admin commission. For instance, a \$100 product will cost \$115 for the customer. 15% will be applied automatically."
                                    .tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger200 : AppThemeData.danger400, fontSize: 14, fontFamily: AppThemeData.medium),
                              ),
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
                                        "Choose a image and upload here".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "JPEG, PNG".tr,
                                        style:
                                            TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Brows Image".tr,
                                        color: AppThemeData.secondary50,
                                        width: 30,
                                        height: 5,
                                        textColor: AppThemeData.secondary300,
                                        onPress: () async {
                                          buildBottomSheet(context, controller);
                                        },
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          controller.images.isEmpty
                              ? const SizedBox()
                              : SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    itemCount: controller.images.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              child: controller.images[index].runtimeType == XFile
                                                  ? Image.file(
                                                      File(controller.images[index].path),
                                                      fit: BoxFit.cover,
                                                      width: 80,
                                                      height: 80,
                                                    )
                                                  : NetworkImageWidget(
                                                      imageUrl: controller.images[index],
                                                      fit: BoxFit.cover,
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: InkWell(
                                                onTap: () {
                                                  controller.images.removeAt(index);
                                                },
                                                child: const Icon(
                                                  Icons.remove_circle,
                                                  size: 28,
                                                  color: AppThemeData.danger300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            title: 'Product Title'.tr,
                            controller: controller.productTitleController.value,
                            hintText: 'Enter product title'.tr,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Product Categories".tr,
                                  style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<VendorCategoryModel>(
                                  hint: Text(
                                    'Select Product Categories'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey700,
                                      fontFamily: AppThemeData.regular,
                                    ),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(color: Colors.red),
                                    isDense: true,
                                    filled: true,
                                    fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                  ),
                                  value: controller.selectedProductCategory.value.id == null ? null : controller.selectedProductCategory.value,
                                  onChanged: (value) {
                                    controller.selectedProductCategory.value = value!;
                                    controller.update();
                                  },
                                  style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                  items: controller.vendorCategoryList.map((item) {
                                    return DropdownMenuItem<VendorCategoryModel>(
                                      value: item,
                                      child: Text(item.title.toString()),
                                    );
                                  }).toList()),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          TextFieldWidget(
                            title: 'Product Description'.tr,
                            controller: controller.productDescriptionController.value,
                            hintText: 'Enter short description here....'.tr,
                            maxLine: 5,
                          ),
                          Text(
                            "Attributes and Prices".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Attributes".tr,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  fontSize: 14,
                                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownSearch<AttributesModel>.multiSelection(
                                items: controller.attributesList,
                                key: controller.myKey1,
                                dropdownButtonProps: DropdownButtonProps(
                                  focusColor: AppThemeData.secondary300,
                                  color: AppThemeData.secondary300,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppThemeData.grey800,
                                  ),
                                ),
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 8, right: 8),
                                      disabledBorder: UnderlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                      ),
                                      filled: true,
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                      fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                      hintText: 'Select Attributes'.tr),
                                ),
                                compareFn: (i1, i2) => i1.title == i2.title,
                                popupProps: PopupPropsMultiSelection.menu(
                                  fit: FlexFit.tight,
                                  showSelectedItems: true,
                                  listViewProps: const ListViewProps(physics: BouncingScrollPhysics(), padding: EdgeInsets.only(left: 20)),
                                  itemBuilder: (context, item, isSelected) {
                                    return ListTile(
                                      selectedColor: AppThemeData.secondary300,
                                      selected: isSelected,
                                      title: Text(
                                        item.title.toString(),
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                      ),
                                      onTap: () {
                                        controller.myKey1.currentState?.popupValidate([item]);
                                      },
                                    );
                                  },
                                ),
                                itemAsString: (AttributesModel u) => u.title.toString(),
                                selectedItems: controller.selectedAttributesList,
                                onSaved: (data) {},
                                onChanged: (data) {
                                  if (controller.itemAttributes.value!.attributes != null) {
                                    controller.selectedAttributesList.clear();
                                    controller.itemAttributes.value!.attributes!.clear();
                                    controller.itemAttributes.value!.variants!.clear();
                                  } else {
                                    controller.itemAttributes.value = ItemAttribute(attributes: [], variants: []);
                                  }
                                  controller.selectedAttributesList.addAll(data);

                                  for (var element in controller.selectedAttributesList) {
                                    controller.addAttribute(element.id.toString());
                                  }
                                  setState(() {});
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              controller.itemAttributes.value!.attributes == null || controller.itemAttributes.value!.attributes!.isEmpty
                                  ? Container()
                                  : Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Attributes Value".tr,
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.semiBold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            ListView.builder(
                                              itemCount: controller.itemAttributes.value!.attributes!.length,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                String title = "";
                                                for (var element in controller.attributesList) {
                                                  if (controller.itemAttributes.value!.attributes![index].attributeId == element.id) {
                                                    title = element.title.toString();
                                                  }
                                                }
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              title,
                                                              style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                                                fontFamily: AppThemeData.medium,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return addAttributeValueDialog(
                                                                      controller, themeChange, index, controller.itemAttributes.value!.attributes![index].attributeId.toString());
                                                                },
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.add,
                                                              color: AppThemeData.secondary300,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Wrap(
                                                        spacing: 4.0,
                                                        runSpacing: 4.0,
                                                        children: List.generate(
                                                          controller.itemAttributes.value!.attributes![index].attributeOptions!.length,
                                                          (i) {
                                                            return InkWell(
                                                                onTap: () {
                                                                  controller.itemAttributes.value!.attributes![index].attributeOptions!.removeAt(i);

                                                                  List<List<dynamic>> listArary = [];
                                                                  for (int i = 0; i < controller.itemAttributes.value!.attributes!.length; i++) {
                                                                    if (controller.itemAttributes.value!.attributes![i].attributeOptions!.isNotEmpty) {
                                                                      listArary.add(controller.itemAttributes.value!.attributes![i].attributeOptions!);
                                                                    }
                                                                  }

                                                                  if (listArary.isNotEmpty) {
                                                                    List<Variants>? variantsTemp = [];
                                                                    List<dynamic> list = getCombination(listArary);
                                                                    for (var element in list) {
                                                                      bool productIsInList =
                                                                          controller.itemAttributes.value!.variants!.any((product) => product.variantSku == element);
                                                                      if (productIsInList) {
                                                                        Variants variant =
                                                                            controller.itemAttributes.value!.variants!.firstWhere((product) => product.variantSku == element);
                                                                        Variants variantsModel = Variants(
                                                                            variantSku: variant.variantSku,
                                                                            variantId: variant.variantId,
                                                                            variantImage: variant.variantImage,
                                                                            variantPrice: variant.variantPrice,
                                                                            variantQuantity: variant.variantQuantity);
                                                                        variantsTemp.add(variantsModel);
                                                                      }
                                                                    }
                                                                    controller.itemAttributes.value!.variants!.clear();
                                                                    controller.itemAttributes.value!.variants!.addAll(variantsTemp);
                                                                  }
                                                                  setState(() {});
                                                                },
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                                  child:
                                                                      _buildChip(themeChange, controller.itemAttributes.value!.attributes![index].attributeOptions![i], index, i),
                                                                ));
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: controller.itemAttributes.value!.variants!.isEmpty
                                                  ? const SizedBox()
                                                  : ClipRRect(
                                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                      child: DataTable(
                                                          horizontalMargin: 20,
                                                          columnSpacing: 30,
                                                          dataRowMaxHeight: 70,
                                                          border: TableBorder.all(
                                                            color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          headingRowColor:
                                                              WidgetStateColor.resolveWith((states) => themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface),
                                                          columns: [
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: Responsive.width(20, context),
                                                                child: Text(
                                                                  "Variant".tr,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: Responsive.width(20, context),
                                                                child: Text(
                                                                  "Price".tr,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: Responsive.width(20, context),
                                                                child: Text(
                                                                  "Quantity".tr,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: SizedBox(
                                                                width: Responsive.width(20, context),
                                                                child: Text(
                                                                  "Image".tr,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          rows: controller.itemAttributes.value!.variants!
                                                              .map(
                                                                (e) => DataRow(
                                                                  cells: [
                                                                    DataCell(
                                                                      Text(
                                                                        e.variantSku.toString(),
                                                                        style: TextStyle(
                                                                          fontFamily: AppThemeData.semiBold,
                                                                          color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      TextFormField(
                                                                        initialValue: e.variantPrice,
                                                                        textCapitalization: TextCapitalization.sentences,
                                                                        textInputAction: TextInputAction.done,
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                                                        ],
                                                                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                        onChanged: (value) {
                                                                          e.variantPrice = value;
                                                                        },
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                            fontFamily: AppThemeData.medium),
                                                                        decoration: InputDecoration(
                                                                          errorStyle: const TextStyle(color: Colors.red),
                                                                          filled: true,
                                                                          enabled: true,
                                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                                          fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                                          disabledBorder: UnderlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide: BorderSide(
                                                                                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          errorBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          hintText: "Price",
                                                                          prefix: Padding(
                                                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                            child: Text(
                                                                              "${Constant.currencyModel!.symbol}".tr,
                                                                              style: TextStyle(
                                                                                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                                  fontFamily: AppThemeData.semiBold,
                                                                                  fontSize: 18),
                                                                            ),
                                                                          ),
                                                                          hintStyle: TextStyle(
                                                                            fontSize: 14,
                                                                            color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                            fontFamily: AppThemeData.regular,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(
                                                                      TextFormField(
                                                                        initialValue: e.variantQuantity,
                                                                        textInputAction: TextInputAction.done,
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                                                                        ],
                                                                        keyboardType: const TextInputType.numberWithOptions( decimal: true),
                                                                        onChanged: (value) {
                                                                          e.variantQuantity = value;
                                                                        },
                                                                        style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                            fontFamily: AppThemeData.medium),
                                                                        decoration: InputDecoration(
                                                                          errorStyle: const TextStyle(color: Colors.red),
                                                                          filled: true,
                                                                          enabled: true,
                                                                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                                          fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                                          disabledBorder: UnderlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide: BorderSide(
                                                                                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          errorBorder: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                            borderSide:
                                                                                BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                          ),
                                                                          hintText: "Quantity",
                                                                          hintStyle: TextStyle(
                                                                            fontSize: 14,
                                                                            color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                            fontFamily: AppThemeData.regular,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataCell(e.variantImage != null && e.variantImage!.isNotEmpty
                                                                        ? InkWell(
                                                                            onTap: () {
                                                                              int index = controller.itemAttributes.value!.variants!
                                                                                  .indexWhere((element) => element.variantId == e.variantId);
                                                                              onCameraClick(context, index, controller);
                                                                            },
                                                                            child: ClipRRect(
                                                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                              child: NetworkImageWidget(
                                                                                height: 50,
                                                                                width: 60,
                                                                                fit: BoxFit.cover,
                                                                                imageUrl: e.variantImage.toString(),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : InkWell(
                                                                            onTap: () {
                                                                              int index = controller.itemAttributes.value!.variants!
                                                                                  .indexWhere((element) => element.variantId == e.variantId);
                                                                              onCameraClick(context, index, controller);
                                                                            },
                                                                            child: SvgPicture.asset("assets/icons/ic_folder_upload.svg"))),
                                                                  ],
                                                                ),
                                                              )
                                                              .toList()),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Regular Price'.tr,
                                  controller: controller.regularPriceController.value,
                                  hintText: 'Enter Regular Price'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Text(
                                      "${Constant.currencyModel!.symbol}".tr,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Discounted Price'.tr,
                                  controller: controller.discountedPriceController.value,
                                  hintText: 'Enter Discounted Price'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  onchange: (value) {
                                    var regularPrice = double.parse(controller.regularPriceController.value.text.toString());
                                    var discountedPrice = double.parse(controller.discountedPriceController.value.text.toString());

                                    if (discountedPrice > regularPrice) {
                                      controller.isDiscountedPriceOk.value = true;
                                      ShowToastDialog.showToast("Please enter valid discount price");
                                    } else {
                                      controller.isDiscountedPriceOk.value = false;
                                    }
                                  },
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Text(
                                      "${Constant.currencyModel!.symbol}".tr,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Your item Price will be display like this.".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 12),
                              ),
                              Text(
                                (controller.discountedPriceController.value.text.toString().trim().isEmpty
                                        ? Constant.amountShow(amount: "0")
                                        : Constant.amountShow(amount: controller.discountedPriceController.value.text))
                                    .tr,
                                style:
                                    TextStyle(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, fontFamily: AppThemeData.medium, fontSize: 12),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                Constant.amountShow(amount: controller.regularPriceController.value.text.isEmpty ? "0" : controller.regularPriceController.value.text),
                                style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                    fontFamily: AppThemeData.medium,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldWidget(
                            title: 'Quantity'.tr,
                            controller: controller.productQuantityController.value,
                            hintText: 'Enter Quantity'.tr,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9-]')),
                            ],
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          ),
                          Text(
                            "-1 to your product quantity is unlimited".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300, fontFamily: AppThemeData.medium, fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "About Cal., Grams, prot.& Fats".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Calories'.tr,
                                  controller: controller.caloriesController.value,
                                  hintText: 'Enter Calories'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Grams'.tr,
                                  controller: controller.gramsController.value,
                                  hintText: 'Enter Grams'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Protein'.tr,
                                  controller: controller.proteinController.value,
                                  hintText: 'Enter Protein'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Fats'.tr,
                                  controller: controller.fatsController.value,
                                  hintText: 'Enter Fats'.tr,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Product Type and Takeaway options".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Pure veg.".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        value: controller.isPureVeg.value,
                                        onChanged: (value) {
                                          if (controller.isNonVeg.value == true) {
                                            controller.isPureVeg.value = value;
                                          }
                                          if (controller.isPureVeg.value == true) {
                                            controller.isNonVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Non veg.".tr,
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        value: controller.isNonVeg.value,
                                        onChanged: (value) {
                                          if (controller.isPureVeg.value == true) {
                                            controller.isNonVeg.value = value;
                                          }

                                          if (controller.isNonVeg.value == true) {
                                            controller.isPureVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Enable Takeaway option".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: controller.takeAway.value,
                                  onChanged: (value) {
                                    controller.takeAway.value = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Specifications and Addons".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Specifications".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 16),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    controller.specificationList.add(ProductSpecificationModel(lable: '', value: ''));
                                  },
                                  child: SvgPicture.asset("assets/icons/ic_add_one.svg"))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: controller.specificationList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        initialValue: controller.specificationList[index].lable,
                                        title: 'Title'.tr,
                                        hintText: 'Enter Title'.tr,
                                        onchange: (value) {
                                          controller.specificationList[index].lable = value;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFieldWidget(
                                        initialValue: controller.specificationList[index].value,
                                        title: 'Value'.tr,
                                        hintText: 'Enter Value'.tr,
                                        onchange: (value) {
                                          controller.specificationList[index].value = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Addons".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 16),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    controller.addonsList.add(ProductSpecificationModel(lable: '', value: ''));
                                  },
                                  child: SvgPicture.asset("assets/icons/ic_add_one.svg"))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.addonsList.length,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        title: 'Title'.tr,
                                        hintText: 'Enter Title'.tr,
                                        initialValue: controller.addonsList[index].lable,
                                        onchange: (value) {
                                          controller.addonsList[index].lable = value;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFieldWidget(
                                        title: 'Price'.tr,
                                        hintText: 'Enter Price'.tr,
                                        initialValue: controller.addonsList[index].value,
                                        prefix: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          child: Text(
                                            "${Constant.currencyModel!.symbol}".tr,
                                            style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                        ],
                                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                        onchange: (value) {
                                          controller.addonsList[index].value = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: Container(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedButtonFill(
                        title: "Save Details".tr,
                        height: 5.5,
                        color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                        textColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          controller.saveDetails();
                        },
                      ),
                    ),
                  ),
                );
        });
  }

  addAttributeValueDialog(AddProductController controller, themeChange, int index, String attributeId) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                title: 'Add Attribute '.tr,
                controller: controller.attributesValueController.value,
                hintText: 'Add Attribute'.tr,
              ),
              RoundedButtonFill(
                title: "Add".tr,
                color: AppThemeData.secondary300,
                textColor: AppThemeData.grey50,
                onPress: () async {
                  if (controller.attributesValueController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter attribute value");
                  } else {
                    Get.back();
                    controller.itemAttributes.value!.attributes![index].attributeOptions!.add(controller.attributesValueController.value.text);

                    List<List<dynamic>> listArary = [];
                    for (int i = 0; i < controller.itemAttributes.value!.attributes!.length; i++) {
                      if (controller.itemAttributes.value!.attributes![i].attributeOptions!.isNotEmpty) {
                        listArary.add(controller.itemAttributes.value!.attributes![i].attributeOptions!);
                      }
                    }

                    List<dynamic> list = getCombination(listArary);

                    for (var element in list) {
                      bool productIsInList = controller.itemAttributes.value!.variants!.any((product) => product.variantSku == element);
                      if (productIsInList) {
                      } else {
                        if (controller.itemAttributes.value!.attributes![index].attributeOptions!.length == 1) {
                          controller.itemAttributes.value!.variants!.clear();
                          Variants variantsModel = Variants(variantSku: element, variantId: Constant.getUuid(), variantImage: "", variantPrice: "0", variantQuantity: "-1");
                          controller.itemAttributes.value!.variants!.add(variantsModel);
                        } else {
                          Variants variantsModel = Variants(variantSku: element, variantId: Constant.getUuid(), variantImage: "", variantPrice: "0", variantQuantity: "-1");
                          controller.itemAttributes.value!.variants!.add(variantsModel);
                        }
                      }
                    }
                    setState(() {});
                    controller.attributesValueController.value.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildBottomSheet(BuildContext context, AddProductController controller) {
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
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
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
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
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

  Widget _buildChip(themeChange, String label, int attributesIndex, int attributesOptionIndex) {
    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
          borderRadius: BorderRadius.circular(120),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.semiBold, fontSize: 14),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.clear,
              color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
              size: 16,
            ),
          ],
        ),
      ),
    );
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

  onCameraClick(BuildContext context, int index, AddProductController controller) {
    final action = CupertinoActionSheet(
      message: const Text(
        'Upload image',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (singleImage != null) {
              ShowToastDialog.showLoader("Image Upload...");

              String image = await FireStoreUtils.uploadUserImageToFireStorage(File(singleImage.path), controller.itemAttributes.value!.variants![index].variantId.toString());
              ShowToastDialog.closeLoader();
              controller.itemAttributes.value!.variants![index].variantImage = image;
              setState(() {});
            }
          },
          child: const Text('Choose image from gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            final XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.camera);
            if (singleImage != null) {
              ShowToastDialog.showLoader("Image Upload...");

              String image = await FireStoreUtils.uploadUserImageToFireStorage(File(singleImage.path), controller.itemAttributes.value!.variants![index].variantId.toString());
              ShowToastDialog.closeLoader();
              controller.itemAttributes.value!.variants![index].variantImage = image;
              setState(() {});
            }
          },
          child: const Text('Take a picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text(
          'Cancel',
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
