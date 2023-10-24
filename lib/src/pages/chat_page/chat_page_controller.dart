part of im_kit;

enum ImChatPageFieldType {
  voice,
  emoji,
  actions,
  none,
}

class ChatPageController extends GetxController with OpenIMListener, ImKitListen, GetTickerProviderStateMixin {
  late Rx<ConversationInfo> conversationInfo;

  late RxList<MessageExt> data;

  late String _secretKey;

  late TabController tabController;

  TextEditingController textEditingController = TextEditingController();

  ChatPageController({
    required String secretKey,
    required List<MessageExt> messages,
    required ConversationInfo conversationInfo,
  }) {
    _secretKey = secretKey;
    data = RxList(messages.reversed.toList());
    this.conversationInfo = Rx(conversationInfo);
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

  final FocusNode focusNode = FocusNode();

  final EasyRefreshController easyRefreshController = EasyRefreshController(controlFinishLoad: true);

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    ImKitIsolateManager.addListener(this);
    super.onInit();
    tabController = TabController(length: 1, vsync: this);
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
      MessageExt extMsg = msg.toExt(_secretKey);
      if (msg.contentType == MessageType.quote) {
        extMsg.ext.quoteMessage = msg.quoteElem!.quoteMessage!.toExt(_secretKey);
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
        await Future.wait(paths.map((e) => ImKitIsolateManager.decryptFile(Utils.getValue(msg.ext.secretKey, _secretKey), e)));
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
        await ImKitIsolateManager.encryptFile(_secretKey, path);
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
        await ImKitIsolateManager.decryptFile(_secretKey, path);
      }
      MessageExt extMsg = newMsg.toExt(_secretKey);
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
    String text = EncryptExtends.ENC_STR_AES_UTF8_ZP(plainText: val, keyStr: _secretKey).base64;
    textEditingController.clear();
    Message msg = await OpenIM.iMManager.messageManager.createTextMessage(text: text);
    MessageExt extMsg = msg.toExt(_secretKey);
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
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad(IndicatorResult.success);
    }
    List<MessageExt> newExts = list.reversed.map((e) => e.toExt(_secretKey)).toList();
    data.addAll(newExts);
    for (var v in newExts) {
      ImCore.downloadFile(v);
    }
  }
}
