part of im_kit;

enum FieldType {
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

  Rx<FieldType> fieldType = FieldType.none.obs;

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    ImKitIsolateManager.addListener(this);
    super.onInit();
    tabController = TabController(length: 1, vsync: this);
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
      downloadFile(v);
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
      downloadFile(extMsg);
    }
  }

  /// 文件下载
  void downloadFile(MessageExt extMsg) {
    if ([MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType)) {
      if ([MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType)) {
        if (extMsg.m.contentType == MessageType.video) {
          ImKitIsolateManager.downloadFiles(extMsg.m.clientMsgID!, [extMsg.m.videoElem?.snapshotUrl ?? '', extMsg.m.videoElem?.videoUrl ?? '']);
        } else {
          String url = extMsg.m.fileElem?.sourceUrl ?? extMsg.m.pictureElem?.sourcePicture?.url ?? extMsg.m.soundElem?.sourceUrl ?? '';
          ImKitIsolateManager.downloadFiles(extMsg.m.clientMsgID!, [url]);
        }
      }
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
    fieldType.value = FieldType.emoji;
  }

  /// 设置为显示功能模块
  void onShowActions() {
    fieldType.value = FieldType.actions;
  }
}
