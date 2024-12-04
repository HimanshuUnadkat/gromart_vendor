import 'package:get/get.dart';
import 'package:store/models/product_model.dart';
import 'package:store/models/user_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class ProductListController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  RxBool isLoading = true.obs;

  getUserProfile() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getProduct();
    isLoading.value = false;
  }

  RxList<ProductModel> productList = <ProductModel>[].obs;

  getProduct() async {
    await FireStoreUtils.getProduct().then(
      (value) {
        if (value != null) {
          productList.value = value;
        }
      },
    );
  }

  updateList(int index,bool isPublish)  async {
    ProductModel productModel = productList[index];
    if(isPublish == true){
      productModel.publish = false;
    }else{
      productModel.publish = true;
    }

    productList.removeAt(index);
    productList.insert(index,productModel);
    update();
    await FireStoreUtils.setProduct(productModel);
  }
}
