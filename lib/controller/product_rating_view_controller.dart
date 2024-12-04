import 'package:get/get.dart';
import 'package:store/models/order_model.dart';
import 'package:store/models/product_model.dart';
import 'package:store/models/rating_model.dart';
import 'package:store/models/review_attribute_model.dart';
import 'package:store/models/vendor_category_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class ProductRatingViewController extends GetxController {

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  RxString productId = "".obs;
  Rx<RatingModel> ratingModel = RatingModel().obs;
  Rx<ProductModel> productModel = ProductModel().obs;
  Rx<VendorCategoryModel> vendorCategoryModel = VendorCategoryModel().obs;

  RxList<ReviewAttributeModel> reviewAttributeList = <ReviewAttributeModel>[].obs;


  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      productId.value = argumentData['productId'];

      await FireStoreUtils.getOrderReviewsByID(orderModel.value.id.toString(),productId.value).then(
        (value) {
          if (value != null) {
            ratingModel.value = value;
          }
        },
      );

      await FireStoreUtils.getProductById(productId.value).then(
            (value) {
          if (value != null) {
            productModel.value = value;
          }
        },
      );

      await FireStoreUtils.getVendorCategoryByCategoryId(productModel.value.categoryID.toString()).then((value) async {
        if (value != null) {
          vendorCategoryModel.value = value;
          for (var element in vendorCategoryModel.value.reviewAttributes!) {
            await FireStoreUtils.getVendorReviewAttribute(element).then((value) {
              reviewAttributeList.add(value!);
            });
          }
        }
      });
    }

    isLoading.value = false;
  }
}
