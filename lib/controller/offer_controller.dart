import 'package:get/get.dart';
import 'package:store/constant/constant.dart';
import 'package:store/models/coupon_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class OfferController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getOffers();
    super.onInit();
  }

  RxList<CouponModel> offerList = <CouponModel>[].obs;

  getOffers() async {
    await FireStoreUtils.getOffer(Constant.userModel!.vendorID.toString()).then(
      (value) {
        offerList.value = value;
      },
    );
    isLoading.value = false;
  }
}
