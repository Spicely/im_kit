part of im_kit;

class IMController extends GetxController with OpenIMListener {
  /// 好友列表
  final RxList<FullUserInfo> friends = <FullUserInfo>[].obs;

  /// 申请列表
  final RxList<ApplicationInfo> applicationList = <ApplicationInfo>[].obs;

  /// 待处理申请数
  final RxInt applicationCount = 0.obs;

  final HotKey _hotFriend = HotKey(KeyCode.keyX, modifiers: [KeyModifier.alt], scope: HotKeyScope.system);

  @override
  void onReady() {
    super.onReady();
    OpenIMManager.addListener(this);
    ever(applicationList, (v) {
      applicationCount.value = v.where((e) => e.handleResult == 0).length;
    });
    getData();
    if (Utils.isDesktop) {
      _initDesktop();
    }
  }

  void _initDesktop() {
    hotKeySystem.register(_hotFriend, keyDownHandler: _screenshot);
  }

  void getData() {
    Utils.exceptionCapture(() async {
      print(applicationList.length);
      friends.value = await OpenIM.iMManager.friendshipManager.getFriendList();
      await getFriendApplication();
    });
  }

  /// 获取好友申请
  Future<void> getFriendApplication() async {
    List<FriendApplicationInfo> friendApplicationList = await OpenIM.iMManager.friendshipManager.getFriendApplicationListAsRecipient();
    // List<GroupApplicationInfo> groupApplication = await OpenIM.iMManager.groupManager.getRecvGroupApplicationList();
    applicationList.assignAll(friendApplicationList.map((e) => e.toApplicationInfo()).toList());
    // applicationList.addAll(groupApplication.map((e) => e.toApplicationInfo()).toList());

    /// 依据reqTime排序
    applicationList.sort((a, b) => (b.reqTime ?? 0).compareTo(a.reqTime ?? 0));
    applicationCount.value = applicationList.where((e) => e.handleResult == 0).length;
  }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
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

  @override
  void onFriendInfoChanged(FriendInfo u) {
    Utils.exceptionCapture(() async {
      int index = friends.indexWhere((v) => v.userID == u.userID);
      if (index != -1) {
        List<FullUserInfo> friendList = await OpenIM.iMManager.userManager.getUsersInfo(uidList: [u.userID!]);
        if (friendList.isNotEmpty) {
          friends[index] = friendList.first;
          friends.refresh();
        }
      }
    });
  }

  @override
  void onFriendApplicationAdded(FriendApplicationInfo u) {
    Utils.exceptionCapture(() async {
      await getFriendApplication();
    });
  }

  @override
  void onFriendApplicationRejected(FriendApplicationInfo u) {
    Utils.exceptionCapture(() async {
      await getFriendApplication();
    });
  }

  @override
  void onFriendApplicationAccepted(FriendApplicationInfo u) {
    Utils.exceptionCapture(() async {
      await getFriendApplication();
    });
  }

  /// 同意好友申请
  void agreeFriendApplication(ApplicationInfo applicationInfo) {
    Utils.exceptionCapture(() async {
      int index = -1;
      if (applicationInfo.type == ApplicationInfoType.friend) {
        await OpenIM.iMManager.friendshipManager.acceptFriendApplication(userID: applicationInfo.id!);
        index = applicationList.indexWhere((v) => v.id == applicationInfo.id);
      } else {
        await OpenIM.iMManager.groupManager.acceptGroupApplication(gid: applicationInfo.groupID!, uid: applicationInfo.id!);
        index = applicationList.indexWhere((v) => v.groupID == applicationInfo.groupID);
      }
      List<FullUserInfo> newFriends = await OpenIM.iMManager.friendshipManager.getFriendsList(userIDList: [applicationInfo.id ?? '']);
      if (newFriends.isNotEmpty) {
        index = friends.indexWhere((v) => v.userID == newFriends.first.userID);
        if (index != -1) {
          friends[index] = newFriends.first;
          friends.refresh();
        } else {
          friends.add(newFriends.first);
          friends.refresh();
        }
      }
      if (index != -1) {
        applicationList[index].handleResult = 1;
        applicationList.refresh();
      }
    });
  }

  /// 拒绝好友申请
  void rejectFriendApplication(ApplicationInfo applicationInfo) {
    Utils.exceptionCapture(() async {
      int index = -1;
      if (applicationInfo.type == ApplicationInfoType.friend) {
        await OpenIM.iMManager.friendshipManager.refuseFriendApplication(userID: applicationInfo.id!);
        index = applicationList.indexWhere((v) => v.id == applicationInfo.id);
      } else {
        await OpenIM.iMManager.groupManager.refuseGroupApplication(gid: applicationInfo.groupID!, uid: applicationInfo.id!);
        index = applicationList.indexWhere((v) => v.groupID == applicationInfo.groupID);
      }
      index = applicationList.indexWhere((v) => v.id == applicationInfo.id);
      if (index != -1) {
        applicationList[index].handleResult = -1;
        applicationList.refresh();
      }
    });
  }
}
