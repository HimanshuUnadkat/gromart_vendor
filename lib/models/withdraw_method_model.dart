class WithdrawMethodModel {
  String? id;
  String? userId;
  FlutterWave? flutterWave;
  Paypal? paypal;
  RazorpayModel? razorpay;
  Stripe? stripe;

  WithdrawMethodModel({this.id, this.userId, this.flutterWave, this.stripe, this.razorpay, this.paypal});

  WithdrawMethodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['userId'] ?? "";
    flutterWave = json['flutterwave'] != null ? FlutterWave.fromJson(json['flutterwave']) : null;
    stripe = json['stripe'] != null ? Stripe.fromJson(json['stripe']) : null;
    razorpay = json['razorpay'] != null ? RazorpayModel.fromJson(json['razorpay']) : null;
    paypal = json['paypal'] != null ? Paypal.fromJson(json['paypal']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    if (flutterWave != null) {
      data['flutterwave'] = flutterWave!.toJson();
    }
    if (razorpay != null) {
      data['razorpay'] = razorpay!.toJson();
    }
    if (paypal != null) {
      data['paypal'] = paypal!.toJson();
    }
    if (stripe != null) {
      data['stripe'] = stripe!.toJson();
    }
    return data;
  }
}

class FlutterWave {
  String? name;
  String? accountNumber;
  String? bankCode;

  FlutterWave({this.name, this.accountNumber, this.bankCode});

  FlutterWave.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "FlutterWave";
    accountNumber = json['accountNumber'];
    bankCode = json['bankCode'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['accountNumber'] = accountNumber;
    data['bankCode'] = bankCode;
    return data;
  }
}

class Stripe {
  String? name;
  String? accountId;

  Stripe({this.name, this.accountId});

  Stripe.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "Stripe";
    accountId = json['accountId'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['accountId'] = accountId;
    return data;
  }
}


class RazorpayModel {
  String? accountId;
  String? name;

  RazorpayModel({this.name, this.accountId});

  RazorpayModel.fromJson(Map<String, dynamic> json) {
    accountId = json['accountId'];
    name = json['name'] ?? "RazorPay";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accountId'] = accountId;
    data['name'] = name;
    return data;
  }
}

class Paypal {
  String? name;
  String? email;

  Paypal({this.name, this.email});

  Paypal.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "PayPal";
    email = json['email'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}
