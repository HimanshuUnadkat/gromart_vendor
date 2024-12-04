import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalModel {
  String? amount;
  String? adminNote;
  String? note;
  String? id;
  Timestamp? paidDate;
  String? paymentStatus;
  String? vendorID;
  String? withdrawMethod;

  WithdrawalModel({this.amount, this.adminNote, this.note, this.id, this.paidDate, this.paymentStatus, this.vendorID, this.withdrawMethod});

  WithdrawalModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'] == null ? "0.0" : json['amount'].toString();
    adminNote = json['adminNote'];
    note = json['note'];
    id = json['id'];
    paidDate = json['paidDate'];
    paymentStatus = json['paymentStatus'];
    vendorID = json['vendorID'];
    withdrawMethod = json['withdrawMethod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['adminNote'] = adminNote;
    data['note'] = note;
    data['id'] = id;
    data['paidDate'] = paidDate;
    data['paymentStatus'] = paymentStatus;
    data['vendorID'] = vendorID;
    data['withdrawMethod'] = withdrawMethod;
    return data;
  }
}
