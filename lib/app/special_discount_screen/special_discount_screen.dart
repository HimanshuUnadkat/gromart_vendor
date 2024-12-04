import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/controller/special_discount_controller.dart';
import 'package:store/themes/app_them_data.dart';
import 'package:store/themes/round_button_fill.dart';
import 'package:store/utils/dark_theme_provider.dart';
import 'package:store/widget/my_separator.dart';

class SpecialDiscountScreen extends StatelessWidget {
  const SpecialDiscountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SpecialDiscountController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Special Discounts".tr,
                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Special Discount amount".tr,
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                            fontSize: 18,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: controller.isSpecialSwitched.value,
                          onChanged: (value) {
                            controller.isSpecialSwitched.value = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: controller.specialDiscount.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${controller.specialDiscount[index].day}".tr,
                                        style: TextStyle(
                                          color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                          fontSize: 18,
                                          fontFamily: AppThemeData.medium,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          controller.addValue(index);
                                        },
                                        child: SvgPicture.asset("assets/icons/ic_add_one.svg"))
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: controller.specialDiscount[index].timeslot!.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, indexTimeSlot) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () async {
                                                    TimeOfDay? startTime = await _selectTime(context);
                                                    controller.specialDiscount[index].timeslot![indexTimeSlot].from = DateFormat('HH:mm')
                                                        .format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime!.hour, startTime.minute));
                                                  },
                                                  child: Container(
                                                    decoration: ShapeDecoration(
                                                      color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].from!.isEmpty
                                                              ? 'Start Time'
                                                              : controller.specialDiscount[index].timeslot![indexTimeSlot].from.toString(),
                                                          style: TextStyle(
                                                              color: controller.specialDiscount[index].timeslot![indexTimeSlot].to!.isEmpty
                                                                  ? themeChange.getThem()
                                                                      ? AppThemeData.grey600
                                                                      : AppThemeData.grey400
                                                                  : themeChange.getThem()
                                                                      ? AppThemeData.grey100
                                                                      : AppThemeData.grey900),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () async {
                                                    TimeOfDay? endTimeOfDay = await _selectTime(context);

                                                    if (endTimeOfDay != null) {
                                                      DateTime endTime =
                                                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endTimeOfDay.hour, endTimeOfDay.minute);
                                                      DateTime time = DateFormat("HH:mm").parse(controller.specialDiscount[index].timeslot![indexTimeSlot].from.toString());
                                                      DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);

                                                      if (startTime.isAfter(endTime)) {
                                                        ShowToastDialog.showToast("Please select Valid Time");
                                                      } else {
                                                        if (endTimeOfDay.format(context).toString() == "12:00 AM") {
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].to =
                                                              DateFormat('HH:mm').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59));
                                                        } else {
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].to = DateFormat('HH:mm').format(
                                                              DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endTimeOfDay.hour, endTimeOfDay.minute));
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: ShapeDecoration(
                                                      color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].to!.isEmpty
                                                              ? 'End Time'
                                                              : controller.specialDiscount[index].timeslot![indexTimeSlot].to.toString(),
                                                          style: TextStyle(
                                                              color: controller.specialDiscount[index].timeslot![indexTimeSlot].to!.isEmpty
                                                                  ? themeChange.getThem()
                                                                      ? AppThemeData.grey600
                                                                      : AppThemeData.grey400
                                                                  : themeChange.getThem()
                                                                      ? AppThemeData.grey100
                                                                      : AppThemeData.grey800),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: TextFormField(
                                                      textAlignVertical: TextAlignVertical.center,
                                                      textInputAction: TextInputAction.next,
                                                      initialValue: controller.specialDiscount[index].timeslot![indexTimeSlot].discount,
                                                      onChanged: (text) {
                                                        controller.specialDiscount[index].timeslot![indexTimeSlot].discount = text;
                                                      },
                                                      keyboardType: TextInputType.number,
                                                      decoration: InputDecoration(
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                                        hintText: 'Discount',
                                                        filled: true,
                                                        isDense: true,
                                                        fillColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
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
                                                        hintStyle: TextStyle(
                                                          fontSize: 14,
                                                          color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                          fontFamily: AppThemeData.regular,
                                                        ),
                                                        suffix: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                                          child: Text(
                                                            controller.specialDiscount[index].timeslot![indexTimeSlot].type == "percentage"
                                                                ? "%"
                                                                : "${Constant.currencyModel!.symbol}".tr,
                                                            style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                fontFamily: AppThemeData.semiBold,
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      )),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: DropdownButtonFormField<String>(
                                                      hint: Text(
                                                        'Select Type'.tr,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey700,
                                                          fontFamily: AppThemeData.regular,
                                                        ),
                                                      ),
                                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                      decoration: InputDecoration(
                                                        errorStyle: const TextStyle(color: Colors.red),
                                                        isDense: true,
                                                        filled: true,
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                                        fillColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
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
                                                      value: controller.specialDiscount[index].timeslot![indexTimeSlot].discountType == "dinein"
                                                          ? "Dine-In Discount"
                                                          : "Delivery Discount",
                                                      onChanged: (value) {
                                                        if (value == "Dine-In Discount") {
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].discountType = "dinein";
                                                        } else {
                                                          controller.specialDiscount[index].timeslot![indexTimeSlot].discountType = "delivery";
                                                        }
                                                        controller.update();
                                                      },
                                                      style: TextStyle(
                                                          fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                                      items: controller.discountType.map((item) {
                                                        return DropdownMenuItem<String>(
                                                          value: item,
                                                          child: Text(item.toString()),
                                                        );
                                                      }).toList()),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: DropdownButtonFormField<String>(
                                                      hint: Text(
                                                        'Select Type'.tr,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey700,
                                                          fontFamily: AppThemeData.regular,
                                                        ),
                                                      ),
                                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                      decoration: InputDecoration(
                                                        errorStyle: const TextStyle(color: Colors.red),
                                                        isDense: true,
                                                        filled: true,
                                                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                                        fillColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
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
                                                      value: controller.specialDiscount[index].timeslot![indexTimeSlot].type == "amount" ? Constant.currencyModel!.symbol : "%",
                                                      onChanged: (value) {
                                                        controller.changeValue(index,indexTimeSlot,value == Constant.currencyModel!.symbol!?"amount":"percentage");
                                                        // if (value == Constant.currencyModel!.symbol!) {
                                                        //   controller.specialDiscount[index].timeslot![indexTimeSlot].type = "amount";
                                                        // } else {
                                                        //   controller.specialDiscount[index].timeslot![indexTimeSlot].type = "percentage";
                                                        // }
                                                        controller.update();
                                                      },
                                                      style: TextStyle(
                                                          fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                                      items: controller.type.map((item) {
                                                        return DropdownMenuItem<String>(
                                                          value: item,
                                                          child: Text(item.toString()),
                                                        );
                                                      }).toList()),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                controller.remove(index, indexTimeSlot);
                                              },
                                              child: Text(
                                                "Remove Discount".tr,
                                                style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300, fontSize: 16, fontFamily: AppThemeData.medium),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RoundedButtonFill(
                  title: "Save Details".tr,
                  height: 5.5,
                  color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                  textColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: () async {
                    bool isEmptyField = false;
                    for (var element in controller.specialDiscount) {
                      var emptyList = element.timeslot!.where((element) =>
                          element.discount!.isEmpty ||
                          element.from!.isEmpty ||
                          element.to!.isEmpty ||
                          (element.type == "percentage" && double.parse(element.discount.toString()) > 100));
                      if (element.timeslot!.isNotEmpty && emptyList.isNotEmpty && !isEmptyField) {
                        ShowToastDialog.showToast("Please enter valid details");
                        isEmptyField = true;
                        continue;
                      }
                    }

                    if (!isEmptyField) {
                      controller.saveSpecialOffer();
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }
}
