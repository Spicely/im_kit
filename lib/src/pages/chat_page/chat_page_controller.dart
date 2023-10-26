part of im_kit;

enum ImChatPageFieldType {
  voice,
  emoji,
  actions,
  none,
}

class ChatPageItem {
  final Tab tab;

  final Widget Function(dynamic) view;

  ChatPageItem({
    required this.tab,
    required this.view,
  });
}

class ChatPageController extends GetxController with OpenIMListener, ImKitListen, GetTickerProviderStateMixin {
  late Rx<ConversationInfo> conversationInfo;

  late RxList<MessageExt> data;

  final String secretKey;

  late TabController tabController;

  final List<ChatPageItem> tabs;

  /// 群成员信息
  late RxList<GroupMembersInfo> groupMembers;

  Rx<GroupInfo>? groupInfo;

  /// 自己的信息
  UserInfo get uInfo => OpenIM.iMManager.uInfo!;

  TextEditingController textEditingController = TextEditingController();

  /// 自己在群里的信息
  GroupMembersInfo? get gInfo => (isGroupChat && groupMembers.isNotEmpty) ? groupMembers.firstWhere((v) => v.userID == uInfo.userID) : null;

  /// 是否是管理员
  bool get isAdmin => gInfo?.roleLevel == GroupRoleLevel.admin;

  /// 是否是群成员
  bool get isMember => gInfo?.roleLevel == GroupRoleLevel.member;

  /// 是否是群主
  bool get isOwner => gInfo?.roleLevel == GroupRoleLevel.owner;

  /// 是否能管理群
  bool get isCanAdmin => gInfo?.roleLevel != GroupRoleLevel.member;

  /// 不允许通过群获取成员资料
  bool get lookMemberInfo => isSingleChat
      ? false
      : isCanAdmin
          ? false
          : groupInfo?.value.lookMemberInfo == 1;

  /// 群id
  String? get gId => Utils.getValue<String?>(conversationInfo.value.groupID, null);

  /// 用户id
  String? get uId => Utils.getValue<String?>(conversationInfo.value.userID, null);

  ChatPageController({
    required this.secretKey,
    required List<MessageExt> messages,
    required ConversationInfo conversationInfo,
    GroupInfo? groupInfo,
    List<GroupMembersInfo>? groupMembers,
    this.tabs = const [],
  }) {
    data = RxList(messages.reversed.toList());
    this.conversationInfo = Rx(conversationInfo);
    if (groupInfo != null) {
      this.groupInfo = Rx(groupInfo);
    }
    this.groupMembers = RxList(groupMembers ?? []);
  }
  ScrollController scrollController = ScrollController();

  /// 群成员信息
  RxList<GroupMembersInfo> groupMemberInfo = RxList([]);

  String? get userID => conversationInfo.value.userID;

  String? get groupID => conversationInfo.value.groupID;

  /// 是单聊
  bool get isSingleChat => conversationInfo.value.isSingleChat;

  /// 是群聊
  bool get isGroupChat => conversationInfo.value.isGroupChat;

  /// 是否有输入内容
  RxBool hasInput = false.obs;

  Rx<ImChatPageFieldType> fieldType = ImChatPageFieldType.none.obs;

  RxBool noMore = false.obs;

  final FocusNode focusNode = FocusNode();

  final EasyRefreshController easyRefreshController = EasyRefreshController(controlFinishLoad: true);

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    ImKitIsolateManager.addListener(this);
    super.onInit();
    tabController = TabController(length: 1 + tabs.length, vsync: this);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        fieldType.value = ImChatPageFieldType.none;
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    getData();
    textEditingController.addListener(() {
      hasInput.value = textEditingController.text.isNotEmpty;
    });
  }

  Future<void> getData() async {
    if (isGroupChat) {
      OpenIM.iMManager.groupManager.getGroupMemberList(groupId: groupID!).then((v) {
        groupMemberInfo.addAll(v);
      });
    }

    /// 下载文件
    for (var v in data) {
      ImCore.downloadFile(v);
    }
  }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
    ImKitIsolateManager.removeListener(this);
    super.onClose();
  }

  @override
  void onRecvNewMessage(Message msg) {
    String? id = Utils.getValue(msg.groupID, msg.sendID);
    if (id == userID || id == groupID || userID == msg.recvID) {
      MessageExt extMsg = msg.toExt(secretKey);
      if (msg.contentType == MessageType.quote) {
        extMsg.ext.quoteMessage = msg.quoteElem!.quoteMessage!.toExt(secretKey);
      }
      data.insert(0, extMsg);
      // markMessageRead([extMsg]);
      ImCore.downloadFile(extMsg);
    }
  }

  @override
  void onDownloadFailure(String id, String error) {
    logger.e(error);
  }

  @override
  void onDownloadProgress(String id, double progress) {
    logger.e(progress);
  }

  @override
  void onDownloadSuccess(String id, List<String> paths) async {
    try {
      MessageExt? msg = data.firstWhereOrNull((v) => v.m.clientMsgID == id);
      if (msg != null) {
        await Future.wait(paths.map((e) => ImKitIsolateManager.decryptFile(Utils.getValue(msg.ext.secretKey, secretKey), e)));
        msg.ext.isDownloading = false;
        if (msg.m.contentType == MessageType.video) {
          msg.ext.previewPath = paths.first;
          msg.ext.path = paths[1];
        } else {
          msg.ext.path = paths.first;
        }
        updateMessage(msg);
      }
    } catch (e) {
      logger.e(e);
    }
  }

  /// 更新消息
  Future<void> updateMessage(MessageExt ext) async {
    int index = data.indexWhere((v) => v.m.clientMsgID == ext.m.clientMsgID);
    if (index != -1) data[index] = ext;
  }

  /// 下载文件
  void onTapDownFile(MessageExt ext) {
    print(ext);
  }

  /// 点击播放视频
  void onTapPlayVideo(MessageExt ext) {
    Get.to(() => ImPlayer(message: ext));
  }

  /// 点击图片
  void onTapPicture(MessageExt ext) {
    /// 获取所有图片
    List<MessageExt> messages = data.where((v) => v.m.contentType == MessageType.picture).toList();
    Get.to(
      () => ImPreview(messages: messages, currentMessage: ext),
      transition: Transition.fadeIn,
    );
  }

  /// 发送消息统一入口
  Future<void> sendMessage(MessageExt msg) async {
    try {
      if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(msg.m.contentType)) {
        /// 先对文件加密
        String path = msg.m.fileElem?.filePath ?? msg.m.pictureElem?.sourcePath ?? msg.m.videoElem?.videoPath ?? msg.m.soundElem?.sourceUrl ?? '';
        await ImKitIsolateManager.encryptFile(secretKey, path);
      }
      Message newMsg = await OpenIM.iMManager.messageManager.sendMessage(
        message: msg.m,
        userID: userID,
        groupID: groupID,
        offlinePushInfo: OfflinePushInfo(title: '新的未读消息'),
      );
      if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(newMsg.contentType)) {
        /// 对文件解密
        String path = newMsg.fileElem?.filePath ?? newMsg.pictureElem?.sourcePath ?? newMsg.videoElem?.videoPath ?? newMsg.soundElem?.sourceUrl ?? '';
        await ImKitIsolateManager.decryptFile(secretKey, path);
      }
      MessageExt extMsg = newMsg.toExt(secretKey);
      updateMessage(extMsg);
    } catch (e) {
      msg.m.status = MessageStatus.failed;
      updateMessage(msg);
    }
  }

  /// 发送消息
  Future<void> onSendMessage() async {
    /// 对< > 转成html
    String val = textEditingController.text.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
    String text = EncryptExtends.ENC_STR_AES_UTF8_ZP(plainText: val, keyStr: secretKey).base64;
    textEditingController.clear();
    Message msg = await OpenIM.iMManager.messageManager.createTextMessage(text: text);
    MessageExt extMsg = msg.toExt(secretKey);
    data.insert(0, extMsg);
    sendMessage(extMsg);
  }

  /// 设置为显示表情
  void onShowEmoji() {
    focusNode.unfocus();
    fieldType.value = ImChatPageFieldType.emoji;
  }

  /// 设置为显示功能模块
  void onShowActions() {
    focusNode.unfocus();
    fieldType.value = ImChatPageFieldType.actions;
  }

  void onUrlTap(String url) {
    Uri uri = Uri.parse(url);
    launchUrl(uri);
  }

  void onTapAt(UserInfo info) {}

  void onTapPhone(String phone) {}

  Future<void> onLoad() async {
    List<Message> list = await OpenIM.iMManager.messageManager.getHistoryMessageList(
      conversationID: conversationInfo.value.conversationID,
      count: 40,
      startMsg: data.last.m,
    );
    if (list.length < 40) {
      noMore.value = true;
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad(IndicatorResult.success);
    }
    List<MessageExt> newExts = list.reversed.map((e) => e.toExt(secretKey)).toList();
    data.addAll(newExts);
    for (var v in newExts) {
      ImCore.downloadFile(v);
    }
  }

  void onNotificationUserTap(UserInfo userInfo) {}

  void onCardTap(MessageExt extMsg) {}
}
