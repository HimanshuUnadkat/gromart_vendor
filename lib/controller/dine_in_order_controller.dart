import 'package:get/get.dart';
import 'package:store/constant/constant.dart';
import 'package:store/models/dine_in_booking_model.dart';
import 'package:store/models/user_model.dart';
import 'package:store/models/vendor_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class DineInOrderController extends GetxController{

  RxBool isLoading  = true.obs;
  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;

  RxList<DineInBookingModel> featureList = <DineInBookingModel>[].obs;
  RxList<DineInBookingModel> historyList = <DineInBookingModel>[].obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
          (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );

    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then(
          (value) {
        if (value != null) {
          vendorModel.value = value;
        }
      },
    );
    await getDineBooking();

    isLoading.value = false;
  }

  getDineBooking() async {
    await FireStoreUtils.getDineInBooking(true).then(
          (value) {
        featureList.value = value;
      },
    );
    await FireStoreUtils.getDineInBooking(false).then(
          (value) {
        historyList.value = value;
      },
    );
  }

}