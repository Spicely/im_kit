part of im_kit;

class ConversationController extends GetxController with OpenIMListener, ImKitListen {
  String get title => unReadMsg.value == 0 ? 'MOYO' : 'MOYO(${unReadMsg.value})';

  RxList<ConversationInfo> data = RxList([]);

  final Rx<dynamic> currentChatPageController = Rx<dynamic>(null);

  /// 待处理申请数
  final RxInt applicationCount = 0.obs;

  /// 申请列表
  final RxList<ApplicationInfo> applicationList = <ApplicationInfo>[].obs;

  /// 好友列表
  final RxList<FullUserInfo> friendList = <FullUserInfo>[].obs;

  /// 黑名单列表
  final RxList<BlacklistInfo> blackList = <BlacklistInfo>[].obs;

  /// 自己信息
  Rx<UserInfo> userInfo = Rx(OpenIM.iMManager.uInfo!);

  /// 已加入群组
  final RxList<GroupInfo> groupList = <GroupInfo>[].obs;

  /// 未读消息
  RxInt unReadMsg = 0.obs;

  TapDownDetails? details;

  /// 当前选中的会话信息
  Rx<String> currentConversationID = ''.obs;

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    ImKitIsolateManager.addListener(this);
    super.onInit();
    ever(applicationList, (v) {
      applicationCount.value = v.where((e) => e.handleResult == 0).length;
    });
    ever(data, (v) {
      // 统计未读数
      int count = 0;
      for (var info in v) {
        if (info.recvMsgOpt == 0) {
          count += info.unreadCount;
        }
      }
      unReadMsg.value = count;
    });
  }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
    ImKitIsolateManager.removeListener(this);
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    getData();
  }

  @override
  void onRecvNewMessage(Message msg) async {
    // if ( msg.contentType == MessageType.memberQuitNotification && msg.notificationElem.) {
    //   return;
    // }
    MessageExt extMsg = await msg.toExt();
    if (extMsg.ext.isBothDelete && extMsg.m.isGroupChat) {
      ImKitIsolateManager._cleanPrivateChatAll();
    }
  }

  // @override
  // void onBlacklistAdded(BlacklistInfo u) {
  //   OpenIM.iMManager.conversationManager.getOneConversation(sourceID: u.userID!, sessionType: ConversationType.single).then((v) {
  //     data.removeWhere((c) => c.conversationID == v.conversationID);
  //     currentConversationID.value = '';
  //     currentChatPageController.value = null;
  //     OpenIM.iMManager.conversationManager.simpleSort(data);
  //   });
  // }

  // @override
  // void onBlacklistDeleted(BlacklistInfo u) {
  //   OpenIM.iMManager.conversationManager.getOneConversation(sourceID: u.userID!, sessionType: ConversationType.single).then((v) {
  //     int index = data.indexWhere((c) => c.conversationID == v.conversationID);
  //     if (index != -1) {
  //       data[index] = v;
  //     } else {
  //       data.add(v);
  //     }
  //     OpenIM.iMManager.conversationManager.simpleSort(data);
  //   });
  // }

  @override
  void onConversationChanged(List<ConversationInfo> list) {
    for (var v in list) {
      if (!v.isValid) return;
      int index = data.indexWhere((element) => element.conversationID == v.conversationID);
      if (index != -1) {
        data[index] = v;
      } else {
        data.add(v);
      }
      if (!v.isValid && v.isSingleChat) {
        data.removeWhere((c) => c.conversationID == v.conversationID);
        currentConversationID.value = '';
        currentChatPageController.value = null;
      }
    }
    OpenIM.iMManager.conversationManager.simpleSort(data);
  }

  @override
  void onNewConversation(List<ConversationInfo> list) {
    for (var v in list) {
      int index = data.indexWhere((element) => element.conversationID == v.conversationID);
      if (index != -1) {
        data[index] = v;
      } else {
        data.add(v);
      }
    }
    OpenIM.iMManager.conversationManager.simpleSort(data);
  }

  Future<void> getData() async {
    data.value = await OpenIM.iMManager.conversationManager.getAllConversationList();
    blackList.value = await OpenIM.iMManager.friendshipManager.getBlackList();

    getApplicationList();
  }

  void getApplicationList() {
    Utils.exceptionCapture(() async {
      List<FriendApplicationInfo> friendApplicationList = await OpenIM.iMManager.friendshipManager.getFriendApplicationListAsRecipient();
      List<GroupApplicationInfo> groupApplication = await OpenIM.iMManager.groupManager.getRecvGroupApplicationList();
      applicationList.assignAll(friendApplicationList.map((e) => e.toApplicationInfo()).toList());
      applicationList.addAll(groupApplication.map((e) => e.toApplicationInfo()).toList());

      /// 依据reqTime排序
      applicationList.sort((a, b) => (b.reqTime ?? 0).compareTo(a.reqTime ?? 0));
      applicationCount.value = applicationList.where((e) => e.handleResult == 0).length;

      friendList.value = await OpenIM.iMManager.friendshipManager.getFriendList();
      groupList.value = await OpenIM.iMManager.groupManager.getJoinedGroupList();

      OpenIM.iMManager.conversationManager.simpleSort(data);
    });
  }

  /// 跳转到聊天页面
  Future<void> toChatPage(ConversationInfo info) async {
    if (Utils.isDesktop) {
      currentConversationID.value = info.conversationID;
    }
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: info.conversationID,
      count: 40,
    );

    List<MessageExt> messages = await advancedMessage.toExt();
    currentChatPageController.value = ChatPageController(messages: messages, conversation: info);
    Get.to(() => ChatPage(controller: currentChatPageController.value));
  }

  Future<void> loadConversation() async {
    List<ConversationInfo> list = await OpenIM.iMManager.conversationManager.getAllConversationList();
    data.value = OpenIM.iMManager.conversationManager.simpleSort(list);
    data.refresh();
  }

  /// 删除会话
  Future<void> deleteConversation(ConversationInfo info) async {
    Get.dialog(
      NoticeDialog(
        title: '通知',
        content: '你正在删除和${info.showName}的聊天记录，这将删除和${info.showName}的所有聊天记录。清空后不可找回，确定要清空当前对话的历史记录吗？',
        onConfirm: () {
          OpenIM.iMManager.conversationManager.deleteConversationAndDeleteAllMsg(conversationID: info.conversationID);
          data.remove(info);
          Get.back();
        },
      ),
    );
  }

  @override
  void onFriendApplicationAdded(FriendApplicationInfo u) {
    getApplicationList();
  }

  @override
  void onJoinedGroupAdded(GroupInfo info) {
    getApplicationList();
  }

  @override
  void onGroupApplicationAdded(GroupApplicationInfo info) {
    getApplicationList();
  }

  @override
  void onGroupApplicationAccepted(GroupApplicationInfo info) {
    getApplicationList();
  }

  @override
  void onFriendInfoChanged(FriendInfo u) {
    int index = friendList.indexWhere((v) => v.userID == u.userID);
    if (index != -1) {
      OpenIM.iMManager.userManager.getUsersInfo(uidList: [u.userID!]).then((value) {
        if (value.isNotEmpty) {
          friendList[index] = value.first;
        }
      });
    }
  }

  @override
  void onSelfInfoUpdated(UserInfo info) {
    // userInfo.update((val) {
    //   val?.birthTime = info.birthTime;
    //   val?.createTime = info.createTime;
    //   val?.gender = info.gender;
    //   val?.userID = info.userID;
    //   val?.allowAddFriend = info.allowAddFriend;
    //   val?.allowBeep = info.allowBeep;
    //   val?.blackInfo = info.blackInfo;
    //   val?.faceURL = info.faceURL;
    //   val?.email = info.email;
    //   val?.birth = info.birth;
    //   val?.phoneNumber = info.phoneNumber;
    //   val?.ex = info.ex;
    // });
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

  /// 移除黑名单好友
  void removeFriendFromBlacklist(String uid) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.friendshipManager.removeBlack(userID: uid);
      int index = blackList.indexWhere((v) => v.userID == uid);
      if (index != -1) {
        blackList.removeAt(index);
        blackList.value = await OpenIM.iMManager.friendshipManager.getBlackList();
      }
    });
  }

  @override
  void onBlackAdded(BlacklistInfo u) {
    int index = blackList.indexWhere((v) => v.userID == u.userID);
    if (index == -1) {
      blackList.add(u);
    }
  }

  @override
  void onBlackDeleted(BlacklistInfo u) {
    blackList.removeWhere((v) => v.userID == u.userID);
  }

  /// 清除聊天页面
  void clearChatPage() {
    currentChatPageController.value = null;
    currentConversationID.value = '';
  }

  /// 会话置顶
  Future<void> setConversationTop(ConversationInfo conversation) async {
    // Get.context?.contextMenuOverlay.hide();
    await OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: conversation.conversationID,
      isPinned: !conversation.isPinned!,
    );
  }

  @override
  void onGroupInfoChanged(GroupInfo info) {
    int index = groupList.indexWhere((v) => v.groupID == info.groupID);
    if (index != -1) {
      groupList[index] = info;
    }
  }

  @override
  void onJoinedGroupDeleted(GroupInfo info) {
    groupList.removeWhere((v) => v.groupID == info.groupID);
  }

  void onTapDown(TapDownDetails dragDownDetails, ConversationInfo info) {
    details = dragDownDetails;
  }

  void onLongPress() {}

  /// 鼠标按下
  void onPointerDown(ConversationInfo conversationInfo, PointerDownEvent event) {
    /// 判断鼠标右键按下
    if (event.buttons == 2) {
      onPointerRightDown(conversationInfo, event);
    }
  }

  /// 鼠标右键按下
  void onPointerRightDown(ConversationInfo conversationInfo, PointerDownEvent event) {}

  /// 消息置顶设置
  Future<void> pinConversation(ConversationInfo conversation, bool status) async {
    await OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: conversation.conversationID,
      isPinned: status,
    );
  }

  /// copy群号
  Future<void> copyGroupID(ConversationInfo conversation) async {
    Clipboard.setData(ClipboardData(text: conversation.groupID ?? ''));
  }

  /// copyID
  Future<void> copyID(ConversationInfo conversation) async {
    Clipboard.setData(ClipboardData(text: conversation.userID ?? ''));
  }

  /// 删除会话
  Future<void> removeConversation(ConversationInfo conversation) async {
    await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversation.conversationID);
    data.removeWhere((v) => v.conversationID == conversation.conversationID);
  }

  /// 标记已读
  Future<void> markConversationRead(ConversationInfo conversation) async {
    await OpenIM.iMManager.messageManager.markMessageAsReadByMsgID(conversationID: conversation.conversationID, messageIDList: []);
  }

  /// 免打扰
  Future<void> setConversationRecvMessageOpt(ConversationInfo conversation, int status) async {
    await OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(conversationIDList: [conversation.conversationID], status: status);
  }

  Future<List<FriendApplicationInfo>> friendListRemoveDuplicateData(List<FriendApplicationInfo> list) async {
    var len = list.length;
    for (var i = 0; i < len; i++) {
      for (var j = i + 1; j < len; j++) {
        if (list[i].fromUserID == list[j].fromUserID && list[i].handleResult == list[j].handleResult) {
          list.removeAt(i);
          len--;
          i--;
        }
      }
    }
    return list;
  }

  Future<List<GroupApplicationInfo>> groupListRemoveDuplicateData(List<GroupApplicationInfo> list) async {
    var len = list.length;
    for (var i = 0; i < len; i++) {
      for (var j = i + 1; j < len; j++) {
        if (list[i].userID == list[j].userID && list[i].handleResult == list[j].handleResult) {
          list.removeAt(i);
          len--;
          i--;
        }
      }
    }
    return list;
  }
}
