import 'dart:convert';
import 'dart:developer';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:store/constant/constant.dart';
import 'package:store/constant/show_toast_dialog.dart';
import 'package:store/models/cart_product_model.dart';
import 'package:store/models/order_model.dart';
import 'package:store/models/tax_model.dart';

class OrderDetailsController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<OrderModel> orderModel = OrderModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxDouble adminComm = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble subTotal = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble specialDiscount = 0.0.obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      for (var element in orderModel.value.products!) {
        if (double.parse(element.discountPrice.toString()) <= 0) {
          subTotal.value = subTotal.value +
              double.parse(element.price.toString()) * double.parse(element.quantity.toString()) +
              (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
        } else {
          subTotal.value = subTotal.value +
              double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
              (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
        }
      }


      if (orderModel.value.specialDiscount != null && orderModel.value.specialDiscount!['special_discount'] != null) {
        specialDiscount.value = double.parse(orderModel.value.specialDiscount!['special_discount'].toString());
      }

      if (orderModel.value.taxSetting != null) {
        for (var element in orderModel.value.taxSetting!) {
          taxAmount.value = taxAmount.value +
              Constant.calculateTax(amount: (subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscount.value).toString(), taxModel: element);
        }
      }

      totalAmount.value = subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscount.value + taxAmount.value;

      if (orderModel.value.adminCommissionType == 'Percent') {
        adminComm.value = (subTotal.value - double.parse(orderModel.value.discount.toString()) - specialDiscount.value) * double.parse(orderModel.value.adminCommission!) / 100;
      } else {
        adminComm.value = double.parse(orderModel.value.adminCommission!);
      }
    }

    isLoading.value = false;
  }

  Future<void> printTicket() async {
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;

    if (isConnected == true) {
      List<int> bytes = await getTicket();
      String base64Image = base64Encode(bytes);

      log(base64Image.toString());

      final result = await PrintBluetoothThermal.writeBytes(bytes);
      if (result == true) {
        ShowToastDialog.showToast("Invoice print successfully");
      }
    } else {
      getBluetooth();
    }
  }

  RxList availableBluetoothDevices = [].obs;

  Future<void> getBluetooth() async {
    final List bluetooths = await PrintBluetoothThermal.pairedBluetooths;
    availableBluetoothDevices.value = bluetooths;
    showLoadingAlert();
  }

  showLoadingAlert() {
    return showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title:  Text('Connect Bluetooth device'.tr),
          content: SizedBox(
            width: double.maxFinite,
            child: availableBluetoothDevices.isEmpty
                ?  Center(child: Text("Please connect device from your bluetooth setting.".tr))
                : ListView.builder(
                    itemCount: availableBluetoothDevices.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String select = availableBluetoothDevices[index];
                          List list = select.split("#");
                          String mac = list[1];
                          setConnect(mac);
                          Navigator.pop(context);
                        },
                        title: Text('${availableBluetoothDevices[index]}'),
                        subtitle:  Text("Click to connect".tr),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> setConnect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (result == true) {
      printTicket();
    }
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    const spaceBetweenColumns = 50;
    const spaceBetweenColumns1 = 10;
    double allTotalProduct = 0.0;
    double totalAddonsPrice = 0.0;

    bytes += generator.text(orderModel.value.vendor!.title.toString(),
        styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true), linesAfter: 1);
    bytes += generator.text(orderModel.value.vendor!.location.toString(), styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Phone: ${orderModel.value.vendor!.phonenumber}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TIN/VAT No.: xxxxxxxxxxxxx', styles: const PosStyles(align: PosAlign.center));
    generator.text(' ' * spaceBetweenColumns, styles: const PosStyles());
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns, styles: const PosStyles());
    bytes += generator.text(orderModel.value.id.toString(), styles: const PosStyles(align: PosAlign.left, bold: true, width: PosTextSize.size1, height: PosTextSize.size2));

    bytes += generator.text(
        'Date: ${DateFormat('MMM d yyyy, h:mm:ss a').format(DateTime.fromMicrosecondsSinceEpoch(orderModel.value.vendor!.createdAt!.microsecondsSinceEpoch)).toString()} ',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.row([
      PosColumn(
        text: 'Type'.tr,
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
        text: orderModel.value.takeAway == false ? 'Deliver to door'.tr : 'Takeaway'.tr,
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.row([
      PosColumn(
        text: 'Item'.tr,
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
        text: 'Price'.tr,
        width: 5,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true,
        ),
      ),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());

    List<CartProductModel> products = orderModel.value.products!;
    for (int i = 0; i < products.length; i++) {
      allTotalProduct += double.parse(products[i].price.toString()) * double.parse(products[i].quantity.toString());
      bytes += generator.row([
        PosColumn(
            text: products[i].name.toString(),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            )),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
        PosColumn(
            text: '${products[i].price} x ${products[i].quantity}',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            )),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
      ]);

      double singleProductTotal = double.parse(products[i].price.toString()) * double.parse(products[i].quantity.toString());
      bytes += generator.row([
        PosColumn(
            text: '',
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            )),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
        PosColumn(
            text: singleProductTotal.toStringAsFixed(Constant.currencyModel!.decimalDigits!),
            width: 5,
            styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
      ]);

      VariantInfo? variantInfo;
      if (products[i].variantInfo != null) {
        variantInfo = products[i].variantInfo;
      }
      if (variantInfo != null)
        for (int l = 0; l < variantInfo.variantOptions!.length; l++) {
          bytes += generator.row([
            PosColumn(
                text: variantInfo.variantOptions!.isEmpty ? '' : "${variantInfo.variantOptions![variantInfo.variantOptions!.keys.elementAt(l)]}",
                width: 5,
                styles: const PosStyles(
                  align: PosAlign.left,
                  height: PosTextSize.size1,
                  width: PosTextSize.size1,
                )),
            PosColumn(
              text: '',
              width: 1, // Spacer column
            ),
            PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
            PosColumn(
              text: '',
              width: 1,
            ),
          ]);
        }

      generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
      bytes += generator.hr(ch: '-', len: 32);
      generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());

      List addOnVal = [];
      List addOnValPrice = [];
      if (products[i].extras == null) {
        addOnVal.clear();
      } else {
        if (products[i].extras is String) {
          if (products[i].extras == '[]') {
            addOnVal.clear();
          } else {
            String extraDecode = products[i].extras.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
            if (extraDecode.contains(",")) {
              addOnVal = extraDecode.split(",");
            } else {
              if (extraDecode.trim().isNotEmpty) {
                addOnVal = [extraDecode];
              }
            }
          }
        }

        if (products[i].extras is List) {
          addOnVal = List.from(products[i].extras!);
        }
      }
      if (products[i].extrasPrice == null) {
        addOnValPrice.clear();
      } else {
        if (products[i].extrasPrice is String) {
          if (products[i].extrasPrice == '[]') {
            addOnValPrice.clear();
          } else {
            String extraDecode = products[i].extrasPrice.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("\"", "");
            if (extraDecode.contains(",")) {
              addOnValPrice = extraDecode.split(",");
            } else {
              if (extraDecode.trim().isNotEmpty) {
                addOnValPrice = [extraDecode];
              }
            }
          }
        }

        if (products[i].extras is List) {
          addOnVal = List.from(products[i].extras ?? []);
        }
        if (products[i].extrasPrice is List) {
          addOnValPrice = List.from(products[i].extras ?? []);
        }
      }
      for (int k = 0; k < addOnVal.length; k++) {
        // Access elements from both lists
        var element = addOnVal[k];
        var element1 = addOnValPrice[k];

        double addonsPrice = double.parse(element1) * double.parse(products[i].quantity.toString());

        bytes += generator.row([
          PosColumn(
              text: element.toString().replaceAll(",", ",\n"),
              width: 5,
              styles: const PosStyles(
                align: PosAlign.left,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
          PosColumn(
            text: '',
            width: 1, // Spacer column
          ),
          PosColumn(
              text: addonsPrice.toString(),
              width: 5,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
          PosColumn(
            text: '',
            width: 1, // Spacer column
          ),
        ]);
        bytes += generator.row([
          PosColumn(
              text: "${element1.toString().replaceAll(",", ",\n")} x ${double.parse(products[i].quantity.toString())}",
              width: 5,
              styles: const PosStyles(
                align: PosAlign.left,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
          PosColumn(
            text: '',
            width: 1, // Spacer column
          ),
          PosColumn(
              text: '',
              width: 5,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              )),
          PosColumn(
            text: '',
            width: 1, // Spacer column
          ),
        ]);

        generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
        bytes += generator.hr(ch: '-', len: 32);
        generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
      }
    }
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.row([
      PosColumn(
          text: 'Subtotal -> Items:',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            //bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: "${allTotalProduct + totalAddonsPrice}",
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());

    for (int i = 0; i < orderModel.value.taxSetting!.length; i++) {
      TaxModel taxModel = orderModel.value.taxSetting![i];
      bytes += generator.row([
        PosColumn(
            text: taxModel.title.toString(),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            )),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
        PosColumn(
            text: Constant.amountShow(
                amount: Constant.calculateTax(
                        amount: (double.parse(subTotal.value.toString()) - double.parse(orderModel.value.discount.toString()) - specialDiscount.value).toString(),
                        taxModel: taxModel)
                    .toString()),
            width: 5,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            )),
        PosColumn(
          text: '',
          width: 1, // Spacer column
        ),
      ]);
    }
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    double totalTaxAmount = 0;

    if (orderModel.value.taxSetting != null) {
      for (var element in orderModel.value.taxSetting!) {
        totalTaxAmount = ((double.parse(subTotal.value.toString()) * (element.tax != null ? double.parse(element.tax!.toString()) : 0.0)) / 100);
      }
    }

    bytes += generator.row([
      PosColumn(
          text: 'Subtotal-> Tax:',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            //bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: totalTaxAmount.toStringAsFixed(Constant.currencyModel!.decimalDigits ?? 2),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);

    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.row([
      PosColumn(
          text: 'Service Charge:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: '0.00',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Delivery Charge:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: orderModel.value.deliveryCharge == null ? "0.0" : double.parse(orderModel.value.deliveryCharge.toString()).toString(),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Delivery Man Tip:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: orderModel.value.tipAmount!.isEmpty ? "0.0" : orderModel.value.tipAmount!,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.row([
      PosColumn(text: 'Grand Total:'.tr, width: 5, styles: const PosStyles(align: PosAlign.left, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: Constant.amountShow(amount: totalAmount.value.toString()),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: double.parse(orderModel.value.discount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits ?? 2),
          width: 5,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total due:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: Constant.amountShow(amount: totalAmount.value.toString()),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Total payment:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(
          text: Constant.amountShow(amount: totalAmount.value.toString()),
          width: 5,
          styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Change due:'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '0', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);

    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    generator.text(' ' * spaceBetweenColumns, styles: const PosStyles());
    bytes += generator.row([
      PosColumn(
          text: 'Billing to : Walkin'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Bill Address: ${orderModel.value.address}'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Bill By: ${orderModel.value.vendor!.authorName}'.tr,
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Table: none',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Order ID: ${orderModel.value.id.toString()}',
          width: 5,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
            bold: true,
          )),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
      PosColumn(text: '', width: 5, styles: const PosStyles(align: PosAlign.right, height: PosTextSize.size1, width: PosTextSize.size1, bold: true)),
      PosColumn(
        text: '',
        width: 1, // Spacer column
      ),
    ]);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns1, styles: const PosStyles());
    bytes += generator.text('Thank you very much'.tr, styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Please do come again!!'.tr, styles: const PosStyles(align: PosAlign.center, bold: true));
    generator.text(' ' * spaceBetweenColumns, styles: const PosStyles());
    bytes += generator.hr(ch: '-', len: 32);
    generator.text(' ' * spaceBetweenColumns, styles: const PosStyles());
    bytes += generator.cut();
    return bytes;
  }
}
