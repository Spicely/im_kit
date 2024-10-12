part of im_kit;

class IMController extends GetxController with OpenIMListener {
  /// 好友列表
  final RxList<FullUserInfo> friends = <FullUserInfo>[].obs;

  /// 申请列表
  final RxList<ApplicationInfo> applicationList = <ApplicationInfo>[].obs;

  /// 待处理申请数
  final RxInt applicationCount = 0.obs;

  /// 未读消息
  RxInt unReadMsg = 0.obs;

  /// 会话列表
  RxList<ConversationInfo> conversations = RxList([]);

  @override
  void onReady() {
    super.onReady();
    OpenIMManager.addListener(this);
    ever(applicationList, (v) {
      applicationCount.value = v.where((e) => e.handleResult == 0).length;
    });
    ever(conversations, (v) {
      // 统计未读数
      int count = 0;
      for (var info in v) {
        if (info.recvMsgOpt == 0) {
          count += info.unreadCount;
        }
      }
      unReadMsg.value = count;
    });
    getData();
  }

  void getData() {
    Utils.exceptionCapture(() async {
      conversations.value = await OpenIM.iMManager.conversationManager.getAllConversationList();
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
    super.onClose();
  }

  @override
  void onConversationChanged(List<ConversationInfo> list) {
    for (var v in list) {
      if (!v.isValid) return;
      int index = conversations.indexWhere((element) => element.conversationID == v.conversationID);
      if (index != -1) {
        conversations[index] = v;
      } else {
        conversations.add(v);
      }
      if (!v.isValid && v.isSingleChat) {
        conversations.removeWhere((c) => c.conversationID == v.conversationID);
      }
    }
    OpenIM.iMManager.conversationManager.simpleSort(conversations);
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
