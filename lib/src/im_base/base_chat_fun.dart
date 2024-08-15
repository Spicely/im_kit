part of '../../im_kit.dart';

class BaseChatFun {
  /// 获取图片
  Future<File?> getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }
}
