import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/constant/collection_name.dart';
import 'package:store/constant/constant.dart';
import 'package:store/models/story_model.dart';
import 'package:store/utils/fire_store_utils.dart';

class AddStoryController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<StoryModel> storyModel = StoryModel().obs;
  final ImagePicker imagePicker = ImagePicker();

  RxList<dynamic> mediaFiles = <dynamic>[].obs;
  RxList<dynamic> thumbnailFile = <dynamic>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getStory();
    super.onInit();
  }

  RxDouble videoDuration = 0.0.obs;

  getStory() async {
    await FireStoreUtils.getStory(Constant.userModel!.vendorID.toString()).then(
      (value) {
        if (value != null) {
          storyModel.value = value;

          thumbnailFile.add(storyModel.value.videoThumbnail);
          for (var element in storyModel.value.videoUrl) {
              mediaFiles.add(element);
            }
        }
      },
    );
    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc('story').get().then((value) {
      videoDuration.value = double.parse(value.data()!['videoDuration'].toString());
    });
    isLoading.value = false;
  }
}
