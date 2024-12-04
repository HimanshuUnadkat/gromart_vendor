import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:store/app/add_restaurant_screen/qr_code_screen.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/add_restaurant_controller.dart';
import 'package:store/models/vendor_category_model.dart';
import 'package:store/models/zone_model.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/responsive.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/themes/text_field_widget.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/utils/network_image_widget.dart';
import 'package:store/widget/place_picker_osm.dart';

class AddRestaurantScreen extends StatelessWidget {
  const AddRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddRestaurantController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Store Details".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RoundedButtonFill(
                    title: "Generate QR Code".tr,
                    width: 38,
                    height: 5,
                    color: AppThemeData.grey50,
                    textColor: AppThemeData.secondary300,
                    onPress: () async {
                      if (controller.vendorModel.value.id == null) {
                        ShowToastDialog.showToast("First save a Store details");
                      } else {
                        Get.to(const QrCodeScreen(), arguments: {"vendorModel": controller.vendorModel.value});
                      }
                    },
                  ),
                ),
              ],
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
                                  height: 90,
                                  child: Column(
                                    children: [
                                      Expanded(
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
                                    ],
                                  ),
                                ),
                          TextFieldWidget(
                            title: 'Store Name'.tr,
                            controller: controller.restaurantNameController.value,
                            hintText: 'Enter Store name'.tr,
                          ),
                          TextFieldWidget(
                            title: 'Store Description'.tr,
                            controller: controller.restaurantDescriptionController.value,
                            maxLine: 5,
                            hintText: 'Enter short description here....'.tr,
                          ),
                          Text(
                            "Mobile number and Address".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            title: 'Phone Number'.tr,
                            controller: controller.mobileNumberController.value,
                            hintText: 'Phone Number'.tr,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              if (controller.addressController.value.text.isEmpty) {
                                Constant.checkPermission(
                                    onTap: () async {
                                      ShowToastDialog.showLoader("Please wait");
                                      try {
                                        await Geolocator.requestPermission();
                                        await Geolocator.getCurrentPosition();
                                        ShowToastDialog.closeLoader();
                                        if (Constant.selectedMapType == 'osm') {
                                          Get.to(() => const LocationPicker())?.then((value) {
                                            if (value != null) {
                                              controller.selectedLocation = LatLng(value.lat, value.lon);
                                              controller.addressController.value.text = value.displayName.toString();
                                              controller.isAddressEnable.value = true;
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: Constant.mapAPIKey,
                                                onPlacePicked: (result) async {
                                                  controller.selectedLocation = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);
                                                  controller.addressController.value.text = result.formattedAddress.toString();
                                                  controller.isAddressEnable.value = true;
                                                  Get.back();
                                                },
                                                initialPosition: const LatLng(-33.8567844, 151.213108),
                                                useCurrentLocation: true,
                                                selectInitialPosition: true,
                                                usePinPointingSearch: true,
                                                usePlaceDetailSearch: true,
                                                zoomGesturesEnabled: true,
                                                zoomControlsEnabled: true,
                                                resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ShowToastDialog.closeLoader();
                                      }
                                    },
                                    context: context);
                              }
                            },
                            child: TextFieldWidget(
                              title: 'Address'.tr,
                              controller: controller.addressController.value,
                              hintText: 'Enter address'.tr,
                              enable: controller.isAddressEnable.value,
                              suffix: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                child: InkWell(
                                  onTap: () {
                                    Constant.checkPermission(
                                      context: context,
                                      onTap: () async {
                                        ShowToastDialog.showToast("Please wait...");
                                        try {
                                          await Geolocator.requestPermission();
                                          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                          ShowToastDialog.closeLoader();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: Constant.mapAPIKey,
                                                onPlacePicked: (result) {
                                                  controller.selectedLocation = LatLng(result.geometry!.location.lat, result.geometry!.location.lng);
                                                  controller.addressController.value.text = result.formattedAddress.toString();
                                                  Get.back();
                                                },
                                                initialPosition: const LatLng(-33.8567844, 151.213108),
                                                useCurrentLocation: true,
                                                selectInitialPosition: true,
                                                usePinPointingSearch: true,
                                                usePlaceDetailSearch: true,
                                                zoomGesturesEnabled: true,
                                                zoomControlsEnabled: true,
                                                resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          print(e.toString());
                                        }
                                      },
                                    );
                                  },
                                  child: Text("change".tr,
                                      style: TextStyle(
                                          fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300)),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Zone".tr,
                                  style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<ZoneModel>(
                                  hint: Text(
                                    'Select zone'.tr,
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
                                  value: controller.selectedZone.value.id == null ? null : controller.selectedZone.value,
                                  onChanged: (value) {
                                    controller.selectedZone.value = value!;
                                    controller.update();
                                  },
                                  style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                  items: controller.zoneList.map((item) {
                                    return DropdownMenuItem<ZoneModel>(
                                      value: item,
                                      child: Text(item.name.toString()),
                                    );
                                  }).toList()),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Service and Categories".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Categories".tr,
                                  style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<VendorCategoryModel>(
                                  hint: Text(
                                    'Select categories'.tr,
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
                                  value: controller.selectedCategory.value.id == null ? null : controller.selectedCategory.value,
                                  onChanged: (value) {
                                    controller.selectedCategory.value = value!;
                                    controller.update();
                                  },
                                  style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                  items: controller.vendorCategoryList.map((item) {
                                    return DropdownMenuItem<VendorCategoryModel>(
                                      value: item,
                                      child: Text(item.title.toString()),
                                    );
                                  }).toList()),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Services".tr,
                                  style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              MultiSelectDialogField(
                                items: [
                                  'Good for Breakfast',
                                  'Good for Lunch',
                                  'Good for Dinner',
                                  'Takes Reservations',
                                  'Vegetarian Friendly',
                                  'Live Music',
                                  'Outdoor Seating',
                                  'Free Wi-Fi'
                                ].map((e) => MultiSelectItem(e, e)).toList(),
                                listType: MultiSelectListType.CHIP,
                                initialValue: controller.selectedService,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    border: Border.all(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50)),
                                onConfirm: (values) {
                                  controller.selectedService.value = values;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Delivery Settings".tr,
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  value: controller.isEnableDeliverySettings.value,
                                  onChanged: (value) {},
                                ),
                              ),
                            ],
                          ),
                          TextFieldWidget(
                            title: 'Charges per KM (distance)'.tr,
                            controller: controller.chargePerKmController.value,
                            hintText: 'Enter charges'.tr,
                            enable: controller.isEnableDeliverySettings.value,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Text(
                                "${Constant.currencyModel!.symbol}".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Min Delivery Charges'.tr,
                            controller: controller.minDeliveryChargesController.value,
                            hintText: 'Enter Min Delivery Charges'.tr,
                            enable: controller.isEnableDeliverySettings.value,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Text(
                                "${Constant.currencyModel!.symbol}".tr,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Min Delivery Charges within KM (distance)'.tr,
                            controller: controller.minDeliveryChargesWithinKMController.value,
                            hintText: 'Enter Min Delivery Charges within KM (distance)'.tr,
                            enable: controller.isEnableDeliverySettings.value,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
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

  buildBottomSheet(BuildContext context, AddRestaurantController controller) {
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
}
