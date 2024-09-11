part of im_kit;

class IMController extends GetxController {
  /// 好友列表
  final RxList<FullUserInfo> friends = <FullUserInfo>[].obs;

  final HotKey _hotFriend = HotKey(KeyCode.keyX, modifiers: [KeyModifier.alt], scope: HotKeyScope.system);

  @override
  void onReady() {
    super.onReady();
    getData();
    if (Utils.isDesktop) {
      _initDesktop();
    }
  }

  void _initDesktop() {
    hotKeySystem.register(_hotFriend, keyDownHandler: _screenshot);
  }

  void getData() async {
    friends.value = await OpenIM.iMManager.friendshipManager.getFriendList();
  }

  @override
  void onClose() {
    if (Utils.isDesktop) {
      hotKeySystem.unregister(_hotFriend);
    }
    super.onClose();
  }

  /// 截屏
  void _screenshot(HotKey event) {
    screenCapturer.capture(
      mode: CaptureMode.region, // screen, window
      imagePath: join(ImCore.tempPath, '${const Uuid().v4()}.png'),
      copyToClipboard: true,
    );
  }
}
