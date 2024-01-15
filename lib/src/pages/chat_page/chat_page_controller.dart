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

class ChatPageController extends GetxController with OpenIMListener, GetTickerProviderStateMixin {
  late Rx<ConversationInfo> conversationInfo;

  late RxList<MessageExt> data;

  late TabController tabController;

  final List<ChatPageItem> tabs;

  RxBool isDrop = false.obs;

  /// 群成员信息
  RxList<GroupMembersInfo> groupMembers = RxList([]);

  /// 群信息
  Rx<GroupInfo?> groupInfo = Rx(null);

  int loadNum = 40;

  /// 自己的信息
  UserInfo get uInfo => OpenIM.iMManager.uInfo!;

  RxInt currentIndex = (-1).obs;

  final TextEditingController textEditingController = TextEditingController();

  /// 自己在群里的信息
  GroupMembersInfo? get gInfo => (isGroupChat && groupMembers.isNotEmpty) ? groupMembers.firstWhere((v) => v.userID == uInfo.userID) : null;

  /// 是否是管理员
  bool get isAdmin => gInfo?.roleLevel == GroupRoleLevel.admin;

  /// 是否是群成员
  bool get isMember => gInfo?.roleLevel == GroupRoleLevel.member;

  /// 是否是群主
  bool get isOwner => gInfo?.roleLevel == GroupRoleLevel.owner;

  /// 聊天人信息
  Rx<FullUserInfo?> chatUserInfo = Rx(null);

  final FcNativeVideoThumbnail nativeVideoThumbnail = FcNativeVideoThumbnail();

  RxBool showSelect = false.obs;

  /// 是否能管理群
  bool get isCanAdmin => gInfo?.roleLevel != GroupRoleLevel.member;

  /// 不允许通过群获取成员资料
  bool get lookMemberInfo => isSingleChat
      ? false
      : isCanAdmin
          ? false
          : groupInfo.value?.lookMemberInfo == 1;

  /// 群id
  String? get gID => Utils.getValue<String?>(conversationInfo.value.groupID, null);

  /// 用户id
  String? get uID => Utils.getValue<String?>(conversationInfo.value.userID, null);

  /// 显示名称
  String get showName => isGroupChat ? '${conversationInfo.value.showName}(${groupMembers.length})' : conversationInfo.value.showName ?? '';

  /// 引用消息
  Rx<MessageExt?> quoteMessage = Rx(null);

  RxList<MessageExt> selectList = RxList([]);

  ChatPageController({
    required List<MessageExt> messages,
    required ConversationInfo conversation,
    this.tabs = const [],
  }) {
    data = RxList(messages.reversed.toList());
    if (data.length < loadNum) {
      noMore.value = true;
    }
    conversationInfo = conversation.obs;
  }
  ScrollController scrollController = ScrollController();

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

  final ItemScrollController itemScrollController = ItemScrollController();

  /// 是否全体禁言
  RxBool isMute = false.obs;

  /// 记录输入框的历史记录
  String historyText = '';

  /// 是否个人禁言
  RxBool isMuteUser = false.obs;

  final List<int> _types = [1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1514, 1515, 1201, 1202, 1203, 1204, 1205, 27, 77, 1512, 1513, 2023, 2024, 2025, 1701];

  /// at用户映射表
  RxList<GroupMembersInfo> atUserMap = RxList<GroupMembersInfo>([]);

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    textEditingController.addListener(_checkHistoryAction);

    ImCore.onPlayerStateChanged(onPlayerStateChanged);
    super.onInit();
    tabController = TabController(length: 1 + tabs.length, vsync: this);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        fieldType.value = ImChatPageFieldType.none;
      }
    });
    isMuteUser.value = userIsMuted(gInfo?.muteEndTime ?? 0);
    computeTime();
  }

  @override
  void onReady() {
    super.onReady();
    getData();

    if (Utils.isNotEmpty(conversationInfo.value.draftText)) {
      textEditingController.text = conversationInfo.value.draftText!;
    }
  }

  @override
  void onProgress(String clientMsgID, dynamic progress) {
    int index = data.indexWhere((v) => v.m.clientMsgID == clientMsgID);
    if (index != -1) {
      data[index].ext.progress = progress / 100;
      data.refresh();
      if (progress == 100) {
        /// 延迟500ms 删除进度
        Future.delayed(const Duration(milliseconds: 500), () {
          data[index].ext.progress = null;
          data.refresh();
        });
      }
    }
  }

  Future<void> onKey(RawKeyEvent event) async {
    /// shift + enter 换行
    if (event is RawKeyDownEvent && event.isShiftPressed && event.logicalKey == LogicalKeyboardKey.enter) {
      return;
    }

    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      await onSendMessage();
      textEditingController.clear();
      return;
    }

    /// macos
    if (event is RawKeyDownEvent) {
      if (Platform.isMacOS) {
        /// 小键盘回车监听
        if (event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          await onSendMessage();
          textEditingController.clear();
        }

        /// 监听粘贴按键组合
        if (event.logicalKey == LogicalKeyboardKey.keyV && event.isMetaPressed) {
          _copyClipboard2Text();
        }
      } else {
        /// 监听粘贴按键组合
        if (event.logicalKey == LogicalKeyboardKey.keyV && event.isControlPressed) {
          _copyClipboard2Text();
        }
      }
    }
  }

  Future<void> _copyClipboard2Text() async {
    Uint8List? imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      String path = await ImKitIsolateManager.saveBytesToTemp(imageBytes);
      textEditingController.text = '${textEditingController.text}${'[file:$path]'}';
      textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
    }
  }

  void onAtDeleteCallback(String id) {
    atUserMap.removeWhere((v) => v.userID == id);
  }

  Future<void> getData() async {
    if (isGroupChat) {
      groupInfo.value = (await OpenIM.iMManager.groupManager.getGroupsInfo(groupIDList: [groupID!])).first;
      if (isMember && groupInfo.value?.status == 3) {
        isMute.value = true;
      }
      groupMembers.value = await OpenIM.iMManager.groupManager.getGroupMemberList(groupId: groupID!);
    } else {
      chatUserInfo.value = (await OpenIM.iMManager.userManager.getUsersInfo(uidList: [uID!])).first;
    }

    List<String> messageIds = [];

    /// 下载文件
    for (var v in data) {
      if (!v.m.isRead! && !_types.contains(v.m.contentType)) {
        messageIds.add(v.m.clientMsgID!);
      }
      downFile(v);

      startTimer(v);
    }
    markMessageAsRead(data);
  }

  void _checkHistoryAction() {
    hasInput.value = textEditingController.text.isNotEmpty;
    if (textEditingController.text.isNotEmpty || textEditingController.text.trim().isNotEmpty) {
      if (textEditingController.text.length == historyText.length + 1 && isGroupChat) {
        /// 获取光标位置
        int index = textEditingController.selection.baseOffset;

        /// 光标前一个字符 == @
        if (textEditingController.text[index - 1] == '@') {
          onAtTriggerCallback();
        }
      }

      /// 对比历史记录 当输入内容比历史记录少@10004467 10004467为userID时触发删除@事件
      if (historyText.length > textEditingController.text.length && isGroupChat) {
        for (var key in atUserMap) {
          GroupMembersInfo? v = key;

          if (!textEditingController.text.contains('@${v.userID} ')) {
            /// 跳出循环
            onAtDeleteCallback(key.userID!);
            break;
          }
        }
      }
    }
    historyText = textEditingController.text;
  }

  /// 标记已读消息
  Future<void> markMessageAsRead(List<MessageExt> messages) async {
    if (messages.isEmpty) return;
    List<MessageExt> msgs = [...messages];

    /// 忽略通知类消息
    List<int> types = [1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1514, 1515, 1201, 1202, 1203, 1204, 1205, 27, 77, 1701, 1512, 1513, 2023, 2024, 2025];
    types.removeWhere((v) => v == 1701);
    msgs.removeWhere((v) => types.contains(v.m.contentType) || v.m.sendID == uInfo.userID || v.m.isRead == true);
    List<String> ids = msgs.map((e) => e.m.clientMsgID!).toList();

    /// 群会话
    // if (Utils.isNotEmpty(groupID) || isGroupChat) {
    //   // await OpenIM.iMManager.messageManager.markGroupMessageAsRead(
    //   //   groupID: groupID ?? conversationInfo.value!.groupID!,
    //   //   messageIDList: [],
    //   // );
    // } else {
    //   if (ids.isEmpty) return;
    //   Utils.exceptionCapture(() async {
    //     await OpenIM.iMManager.messageManager.markC2CMessageAsRead(userID: userID ?? uId!, messageIDList: ids);
    //     // await OpenIM.iMManager.messageManager.markMessageAsReadByConID(conversationID: conversationID, messageIDList: []);
    //     OpenIM.iMManager.messageManager.mar(userID: userID ?? uId, groupID: groupID ?? gId, messageIDList: []);
    //   });
    // }

    OpenIM.iMManager.messageManager.markMessageAsReadByMsgID(conversationID: conversationInfo.value.conversationID, messageIDList: ids);
  }

  /// @触发事件
  void onAtTriggerCallback() async {}

  void addAtUserMap(GroupMembersInfo info) {
    int index = atUserMap.indexWhere((v) => v.userID == info.userID);
    if (index == -1) {
      atUserMap.add(info);
    }
  }

  /// 双击打开文件目录
  void onDoubleTapFile(MessageExt extMsg) {
    // if (Utils.isDesktop) {
    //   OpenIM.iMManager.messageManager.downloadFileReturnPaths(message: extMsg.m).then((paths) async {
    //     String? savePath = await FilePicker.platform.saveFile(
    //       dialogTitle: '保存文件',
    //       fileName: extMsg.m.fileElem?.fileName ?? '',
    //     );
    //     if (savePath != null) {
    //       ImKitIsolateManager.copyFile(paths.first, savePath);
    //     }
    //   }).catchError((e) {
    //     extMsg.ext.errorCode = ImExtErrorCode.downloadFailure;
    //     updateMessage(extMsg);
    //   });
    // }
  }

  // @override
  // void onDownloadFileProgress(String taskId, int progress) {
  //   int index = data.indexWhere((v) => v.m.clientMsgID == taskId);
  //   if (index != -1) {
  //     data[index].ext.progress = progress / 100;
  //     data.refresh();
  //     if (progress == 100) {
  //       /// 延迟500ms 删除进度
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         data[index].ext.progress = null;
  //         data.refresh();
  //       });
  //     }
  //   }
  // }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
    textEditingController.removeListener(_checkHistoryAction);
    for (var i in data) {
      if (i.ext.isPrivateChat) {
        OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(message: i.m);
      }
    }

    /// 设置草稿
    if (textEditingController.text.trim().isNotEmpty) {
      OpenIM.iMManager.conversationManager.setConversationDraft(
        conversationID: conversationInfo.value.conversationID,
        draftText: textEditingController.text,
      );
    }

    /// 清空草稿
    if (Utils.isNotEmpty(conversationInfo.value.draftText) && textEditingController.text.isEmpty) {
      OpenIM.iMManager.conversationManager.setConversationDraft(
        conversationID: conversationInfo.value.conversationID,
        draftText: '',
      );
    }

    super.onClose();
  }

  @override
  void onRecvNewMessage(Message msg) {
    String? id = Utils.getValue(msg.groupID, msg.sendID);
    if (id == userID || id == groupID || userID == msg.recvID) {
      msg.toExt().then((extMsg) async {
        if (msg.contentType == MessageType.quote) {
          extMsg.ext.quoteMessage = await msg.quoteElem!.quoteMessage!.toExt();
        }
        data.insert(0, extMsg);
        computeTime();
        if (!_types.contains(extMsg.m.contentType)) {
          markMessageAsRead([extMsg]).then((_) {
            startTimer(extMsg);
          });
        }
        downFile(extMsg);
      });
    }
    if (isGroupChat && msg.isGroupChat && conversationInfo.value.groupID == msg.groupID) {
      msg.toExt().then((v) {
        if (v.ext.isGroupBothDelete) {
          onGroupBothMessageDelete(v);
        }
      });
    }
  }

  void downFile(MessageExt extMsg) async {
    // if (extMsg.m.clientMsgID == null) return;

    // if ([MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType) || [MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.quoteElem?.quoteMessage?.contentType)) {
    //   try {
    //     List<String> files = await OpenIM.iMManager.messageManager.downloadFileReturnPaths(message: extMsg.m);
    //     if (files.length == 2) {
    //       extMsg.ext.previewFile = File(files.first);
    //       extMsg.ext.file = File(files.last);
    //     } else {
    //       extMsg.ext.file = File(files.first);
    //     }
    //     updateMessage(extMsg);
    //   } catch (e) {
    //     debugPrint(e.toString());
    //     extMsg.ext.errorCode = ImExtErrorCode.downloadFailure;
    //     updateMessage(extMsg);
    //   }
    // }
  }

  @override
  void onGroupMemberInfoChanged(GroupMembersInfo info) {
    if (isGroupChat && groupMembers.isNotEmpty) {
      if (info.userID == uInfo.userID) {
        updateGroupMemberInfo(info);
      } else {
        /// 更新群成员信息
        int index = groupMembers.indexWhere((v) => v.userID == info.userID);
        if (index != -1) {
          groupMembers[index] = info;
        }
      }
    }
  }

  @override
  void onGroupMemberDeleted(GroupMembersInfo info) {
    groupMembers.removeWhere((v) => v.userID == info.userID);
  }

  @override
  void onGroupMemberAdded(GroupMembersInfo info) {
    groupMembers.add(info);
  }

  @override
  void onRecvC2CMessageReadReceipt(List<ReadReceiptInfo> list) {
    for (var readInfo in list) {
      for (var msgID in (readInfo.msgIDList ?? [])) {
        /// 依据 msgID 查找到data里的消息
        int index = data.indexWhere((v) => v.m.clientMsgID == msgID);
        if (index != -1) {
          data[index].m.isRead = true;
          data[index].m.createTime = readInfo.readTime;
          updateMessage(data[index]);
          startTimer(data[index]);
        }
      }
    }
  }

  Future<void> setGroupInfo({String? groupName, String? notification, String? introduction, String? faceUrl, String? ex}) async {
    await OpenIM.iMManager.groupManager.setGroupInfo(
      groupID: gID!,
      introduction: introduction,
      notification: notification,
      faceUrl: faceUrl,
      groupName: groupName,
      ex: ex,
    );
  }

  // @override
  // void onRecvMessageRevoked(String msgId) {
  //   int index = data.indexWhere((v) => v.m.clientMsgID == msgId);
  //   if (index != -1) {
  //     data.removeAt(index);
  //   }
  // }

  /// 结束拖动文件
  void onDragExited(DropEventDetails detail) {
    isDrop.value = false;
  }

  /// 开始拖动文件
  void onDragEntered(DropEventDetails detail) {
    isDrop.value = true;
  }

  /// 文件拖动完成
  Future<void> onDragDone(DropDoneDetails detail) async {
    final files = detail.files;
    for (var file in files) {
      /// 获取后缀名
      String suffix = file.path.split('.').last;

      Message msg;

      /// 判断是不是图片
      if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(suffix)) {
        msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path);
      }

      /// 判断视频
      /*else if (['mp4', 'avi', '3gp', 'mkv'].contains(suffix)) {

        await nativeVideoThumbnail.getVideoThumbnail(srcFile: file.path, destFile: destFile, width: 300, height: 600, keepAspectRatio: true, format: 'jpeg', quality: 90);
        msg = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(videoPath: file.path, videoType: suffix, duration: 0, snapshotPath: destFile);
      }*/
      else {
        msg = await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(filePath: file.path, fileName: file.name);
      }

      MessageExt extMsg = await msg.toExt();
      extMsg.ext.file = File(file.path);
      data.insert(0, extMsg);
      sendMessage(extMsg);
    }
  }

  @override
  void onGroupInfoChanged(GroupInfo info) {
    groupInfo = Rx(info);
    if (isMember && info.status == 3) {
      isMute.value = true;
      fieldType.value = ImChatPageFieldType.none;
    } else {
      isMute.value = false;
    }
  }

  /// 聊天页面时间展示的最小差
  bool _check2TimeGap(int t1, int t2) {
    if ((t1 - t2).abs() > 1000 * 60 * 3) return true;
    return false;
  }

  Future<void> onQuoteMessageTap(MessageExt msgExt) async {
    int index = data.indexWhere((v) => v.m.clientMsgID == msgExt.ext.quoteMessage?.m.clientMsgID);
    if (index != -1) {
      currentIndex.value = index;
      itemScrollController.jumpTo(index: index);
    } else {
      AdvancedMessage result = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
        conversationID: conversationInfo.value.conversationID,
        startMsg: msgExt.m,
      );
      List<MessageExt> newExts = (await Future.wait(result.messageList.map((e) => e.toExt()))).reversed.toList();

      /// 移除已经有了的数据
      newExts.removeWhere((v) => data.indexWhere((e) => e.m.clientMsgID == v.m.clientMsgID) != -1);
      for (var v in newExts) {
        downFile(v);
      }
      data.addAll(newExts);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        int index = data.indexWhere((v) => v.m.clientMsgID == msgExt.ext.quoteMessage?.m.clientMsgID);
        if (index != -1) {
          currentIndex.value = index;
          itemScrollController.jumpTo(index: index);
        }
      });

      itemScrollController.jumpTo(index: data.length);
    }

    /// 2s 后清除引用消息
    Future.delayed(const Duration(seconds: 2), () {
      currentIndex.value = -1;
    });
  }

  /// 计算时间
  void computeTime() {
    for (int i = 0; i < data.length; i++) {
      int index = i + 1;
      MessageExt message = data[i];
      if (index >= data.length) {
        continue;
      }

      MessageExt lastMessage = data[index];
      if (_check2TimeGap(message.m.sendTime ?? message.m.createTime!, lastMessage.m.sendTime ?? lastMessage.m.createTime!)) {
        message.ext.showTime = true;
      } else {
        message.ext.showTime = false;
      }
    }
    data.refresh();
  }

  /// 引用消息删除事件
  void onQuoteMessageDelete() {
    quoteMessage.value = null;
  }

  /// 引用消息
  void onQuoteMessage(MessageExt msg) async {
    focusNode.requestFocus();
    quoteMessage.value = msg;
  }

  /// 更新消息
  Future<void> updateMessage(MessageExt ext) async {
    int index = data.indexWhere((v) => v.m.clientMsgID == ext.m.clientMsgID);
    if (index != -1) {
      File? file = data[index].ext.file;
      File? previewFile = data[index].ext.previewFile;
      data[index] = ext;
      if (file != null) {
        /// 路径还原避免闪烁
        data[index].ext.file = file;
      }
      if (previewFile != null) {
        /// 路径还原避免闪烁
        data[index].ext.previewFile = previewFile;
      }
    }
  }

  /// 发送图片
  Future<void> onSendImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          Message msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path!);
          MessageExt extMsg = await msg.toExt();
          extMsg.ext.file = File(file.path!);
          data.insert(0, extMsg);
          sendMessage(extMsg);
        }
      }
    }
  }

  /// 发送文件
  Future<void> onSendFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          /// 获取后缀名
          String? suffix = file.extension;

          Message msg;

          /// 判断是不是图片
          if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(suffix)) {
            msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path!);
          }

          /// 判断视频
          /* else if (['mp4', 'avi', '3gp', 'mkv'].contains(suffix)) {
            await nativeVideoThumbnail.getVideoThumbnail(srcFile: file.path!, destFile: file.path!, width: 300, height: 600, keepAspectRatio: true, format: 'jpeg', quality: 90);
            msg = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(videoPath: file.path!, videoType: suffix!, duration: 0, snapshotPath: file.path!);
          }*/
          else {
            msg = await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(filePath: file.path!, fileName: file.name);
          }

          MessageExt extMsg = await msg.toExt();
          extMsg.ext.file = File(file.path!);
          data.insert(0, extMsg);
          sendMessage(extMsg);
        }
      }
    }
  }

  /// 下载文件
  void onTapDownFile(BuildContext context, MessageExt ext) {
    // OpenIM.iMManager.
  }

  /// 点击播放视频
  void onTapPlayVideo(BuildContext context, MessageExt ext) {
    Get.to(() => ImPlayer(message: ext));
  }

  /// 点击图片
  void onPictureTap(MessageExt extMsg) {
    if (extMsg.ext.file == null) return;

    /// 获取所有图片
    List<MessageExt> messages = data.where((v) => v.m.contentType == MessageType.picture).toList();
    Get.to(
      () => ImPreview(messages: messages, currentMessage: extMsg),
      transition: Transition.fadeIn,
    );
  }

  /// 设置草稿
  Future<void> setConversationDraft(String draft) async {
    await OpenIM.iMManager.conversationManager.setConversationDraft(
      conversationID: conversationInfo.value.conversationID,
      draftText: draft,
    );
  }

  /// 发送消息统一入口
  Future<MessageExt> sendMessage(
    MessageExt msg, {
    String? userId,
    String? groupId,
    String? text,
  }) async {
    if (Utils.isNotEmpty(conversationInfo.value.draftText)) {
      setConversationDraft('');
    }
    // ignore: non_constant_identifier_names
    String? u_id;
    // ignore: non_constant_identifier_names
    String? g_id;
    if (Utils.isNotEmpty(userId) || Utils.isNotEmpty(groupId)) {
      u_id = userId;
      g_id = groupId;
    } else {
      u_id = uID;
      g_id = gID;
    }
    try {
      Message newMsg = await OpenIM.iMManager.messageManager.sendMessage(
        message: msg.m,
        userID: u_id,
        groupID: g_id,
        offlinePushInfo: OfflinePushInfo(title: '新的未读消息'),
      );
      if (text != null) {
        switch (newMsg.contentType) {
          case MessageType.atText:
          case MessageType.text:
          case MessageType.quote:
            newMsg.textElem?.content = text;
            newMsg.atTextElem?.text = text;
            newMsg.quoteElem?.text = text;
        }
      }
      MessageExt extMsg = await newMsg.toExt();
      return extMsg;
    } catch (e) {
      msg.m.status = MessageStatus.failed;
      updateMessage(msg);
      return msg;
    }
  }

  /// 更新自己在群里的信息
  void updateGroupMemberInfo(GroupMembersInfo info) {
    if (isGroupChat) {
      int index = groupMembers.indexWhere((v) => v.userID == info.userID);
      if (index != -1) {
        groupMembers[index] = info;
        isMuteUser.value = userIsMuted(gInfo?.muteEndTime ?? 0);
      }
    }
  }

  /// 用户是否被禁言
  bool userIsMuted(num? muteEndTime) {
    if (muteEndTime == null || muteEndTime == 0 || muteEndTime < (DateTime.now().millisecondsSinceEpoch / 1000)) {
      return false;
    }
    return true;
  }

  /// 用户被禁言剩余的时间
  int userMutedTime(num? muteEndTime) {
    if (muteEndTime == null || muteEndTime == 0 || muteEndTime < (DateTime.now().millisecondsSinceEpoch / 1000)) {
      return 0;
    }
    return (muteEndTime - DateTime.now().millisecondsSinceEpoch / 1000) ~/ 3600;
  }

  Future<void> setGroupVerification(int needVerification) async {
    await OpenIM.iMManager.groupManager.setGroupVerification(groupID: gID!, needVerification: needVerification);
  }

  Future<void> changeGroupMute(bool mute) async {
    await OpenIM.iMManager.groupManager.changeGroupMute(groupID: gID!, mute: mute);
  }

  /// 发送消息
  Future<void> onSendMessage() async {
    String value = textEditingController.text;
    if (value.trim().isEmpty) return;
    MessageExt? message;
    try {
      /// 清空输入框
      MessageExt? quoteMsg = quoteMessage.value;

      textEditingController.clear();

      List<String> files = [];

      value = value.splitMapJoin(
        RegExp(r"\[file:[^\]]+\]"),
        onMatch: (Match m) {
          String? path = m.group(0);
          if (path != null) {
            path = path.replaceFirst('[file:', '').replaceFirst(']', '');
            files.add(path);
          }
          return '';
        },
      );

      if (value.isNotEmpty) {
        /// 创建@消息
        List<AtUserInfo> list = atUserMap.map((v) => AtUserInfo(atUserID: v.userID, groupNickname: v.nickname)).toList();
        if (atUserMap.isNotEmpty) {
          message = await createTextAtMessage(list, value, quoteMessage: quoteMsg?.m);
        } else if (quoteMsg != null) {
          message = await createQuoteMessage(value, quoteMsg.m);
        } else {
          message = await createTextMessage(value);
        }
        quoteMessage.value = null;
        atUserMap.clear();
        data.insert(0, message);

        if (data.length > 5) {
          itemScrollController.jumpTo(index: 0);
        }
        message = await sendMessage(message, text: value);
        updateMessage(message);
      }

      /// 发送图片消息
      for (var f in files) {
        Message msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: f);
        MessageExt extMsg = await msg.toExt();
        extMsg.ext.file = File(f);
        data.insert(0, extMsg);
        sendMessage(extMsg);
      }
    } catch (e) {
      if (message != null) {
        /// 发送失败 修改状态
        message.m.status = MessageStatus.failed;
        updateMessage(message);
      }
    }
  }

  /// 创建文本消息
  Future<MessageExt> createTextMessage(String val) async {
    /// 对< > 转成html
    val = val.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
    Message msg = await OpenIM.iMManager.messageManager.createTextMessage(text: val);
    return await msg.toExt();
  }

  /// 创建引用
  Future<MessageExt> createQuoteMessage(String text, Message quoteMsg) async {
    return await (await OpenIM.iMManager.messageManager.createQuoteMessage(
      text: text,
      quoteMsg: quoteMsg,
    ))
        .toExt();
  }

  /// 创建@消息
  Future<MessageExt> createTextAtMessage(List<AtUserInfo> atUserInfoList, String text, {Message? quoteMessage}) async {
    var regexAt = atUserInfoList.map((e) => '@${e.atUserID} ').toList().join('|');

    /// 替换text中的@字符串
    text = text.splitMapJoin(
      RegExp(regexAt),
      onMatch: (m) {
        String value = m.group(0)!;
        String id = value.split('#').first.replaceFirst('@', '').trim();

        return '@$id ';
      },
      onNonMatch: (n) => n,
    );

    return await (await OpenIM.iMManager.messageManager.createTextAtMessage(
      text: text,
      atUserIDList: atUserInfoList.map((e) => e.atUserID ?? '').toList(),
      atUserInfoList: atUserInfoList,
      quoteMessage: quoteMessage,
    ))
        .toExt();
  }

  /// 设置为显示表情
  void onShowEmoji() {
    focusNode.unfocus();
    fieldType.value = ImChatPageFieldType.emoji;
  }

  void onVoiceChanged() {
    if (fieldType.value == ImChatPageFieldType.voice) {
      fieldType.value = ImChatPageFieldType.none;
    } else {
      focusNode.unfocus();
      fieldType.value = ImChatPageFieldType.voice;
    }
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

  void onAtTap(TapUpDetails details, FullUserInfo userInfo) {}

  void onTapPhone(String phone) {}

  void onForwardMessage(MessageExt extMsg) {}

  Future<void> onLoad() async {
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: conversationInfo.value.conversationID,
      count: loadNum,
      startMsg: data.last.m,
    );
    if (advancedMessage.messageList.length < loadNum) {
      noMore.value = true;
      easyRefreshController.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController.finishLoad(IndicatorResult.success);
    }
    List<MessageExt> newExts = await Future.wait(advancedMessage.messageList.reversed.map((e) => e.toExt()));
    data.addAll(newExts);
    // if (advancedMessage.messageList.length < loadNum) {
    //   MessageExt encryptedNotification = await Message(
    //     contentType: MessageType.encryptedNotification,
    //     createTime: list.isEmpty ? DateTime.now().millisecondsSinceEpoch : data.last.m.createTime,
    //   ).toExt();
    //   data.add(encryptedNotification);
    // }
    for (var v in newExts) {
      downFile(v);
    }
  }

  void onNotificationUserTap(TapUpDetails details, FullUserInfo userInfo) {}

  void onCardTap(MessageExt extMsg) {}

  void onLocationTap(MessageExt extMsg) {}

  void onFileTap(MessageExt extMsg) {}

  void onVoiceTap(MessageExt extMsg) {
    if (extMsg.ext.isPlaying) {
      ImCore.stop();
    } else {
      ImCore.play(extMsg.m.clientMsgID!, extMsg.ext.file!.path, onPlayerBeforePlay: onPlayerBeforePlay);
    }
    extMsg.ext.isPlaying = !extMsg.ext.isPlaying;
    updateMessage(extMsg);
  }

  void onPlayerBeforePlay(String id) {
    MessageExt? msg = data.firstWhereOrNull((v) => v.m.clientMsgID == id);
    if (msg != null) {
      msg.ext.isPlaying = false;
      updateMessage(msg);
    }
  }

  /// 播放回调
  void onPlayerStateChanged(a.PlayerState state, String id) {
    if (state == a.PlayerState.completed) {
      MessageExt? msg = data.firstWhereOrNull((v) => v.m.clientMsgID == id);
      if (msg != null) {
        msg.ext.isPlaying = false;
        updateMessage(msg);
      }
    }
  }

  /// 完成录制
  void onRecordSuccess(String path, int duration) async {
    // ImKitIsolateManager.copyFile(path).then((savePath) {
    //   OpenIM.iMManager.messageManager.createSoundMessageFromFullPath(soundPath: savePath, duration: duration).then((msg) {
    //     msg.toExt().then((extMsg) {
    //       extMsg.ext.file = File(path);
    //       data.insert(0, extMsg);
    //       sendMessage(extMsg);
    //     });
    //   });
    // });
  }

  @override
  void onConversationChanged(List<ConversationInfo> list) {
    for (var v in list) {
      if (v.conversationID == conversationInfo.value.conversationID) {
        conversationInfo.value = v;
        continue;
      }
    }
  }

  void onCopyTip(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void onDeleteMessage(MessageExt extMsg) {}

  /// 设置会话置顶
  void setPinConversation(bool status, {String? conversationID}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.pinConversation(conversationID: conversationID ?? conversationInfo.value.conversationID, isPinned: status);
    });
  }

  /// 设置消息免打扰
  ///
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<void> setConversationRecvMessageOpt(int status, {List<String>? conversationIDList}) async {
    await OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(conversationIDList: conversationIDList ?? [conversationInfo.value.conversationID], status: status);
  }

  /// 删除聊天记录
  Future<void> clearHistoryMessage() async {
    if (isGroupChat) {
      assert(gID != null, 'gId 不能为空');
      await OpenIM.iMManager.messageManager.clearGroupHistoryMessage(gid: gID!);
    } else {
      assert(uID != null, 'uId 不能为空');
      await OpenIM.iMManager.messageManager.clearC2CHistoryMessage(uid: uID!);
    }
  }

  /// 退出群聊
  void quitGroup() {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.quitGroup(gid: gID!);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value.conversationID);
    });
  }

  /// 解散群聊
  Future<void> dismissGroup() async {
    await OpenIM.iMManager.groupManager.dismissGroup(groupID: gID!);
    await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value.conversationID);
  }

  /// 已被加入黑名单
  @override
  void onBlackAdded(BlacklistInfo u) {
    if (u.userID == uID) {
      Utils.exceptionCapture(() async {
        chatUserInfo.value = (await OpenIM.iMManager.userManager.getUsersInfo(uidList: [uID!])).first;
      });
    }
  }

  /// 已从黑名单移除
  @override
  void onBlackDeleted(BlacklistInfo u) {
    if (u.userID == uID) {
      Utils.exceptionCapture(() async {
        chatUserInfo.value = (await OpenIM.iMManager.userManager.getUsersInfo(uidList: [uID!])).first;
      });
    }
  }

  Future<Message> createCardMessage(UserInfo user) async {
    return await OpenIM.iMManager.messageManager.createCardMessage(
      data: {'userID': user.userID, 'nickname': user.nickname, 'faceURL': user.faceURL},
    );
  }

  /// 转发消息
  Future<MessageExt> createForwardMessage(Message msg, String sessionID, int sessionType) async {
    return await (await OpenIM.iMManager.messageManager.createForwardMessage(message: msg)).toExt();
  }

  void onMultiSelectTap(MessageExt extMsg) async {
    showSelect.value = true;
  }

  void onMessageSelect(MessageExt msg, bool status) {
    if (status) {
      /// 判断消息是否已经被存储
      int index = selectList.indexWhere((v) => v.m.clientMsgID == msg.m.clientMsgID);
      if (index == -1) {
        selectList.add(msg);
      } else {
        selectList[index] = msg;
      }
    } else {
      selectList.removeWhere((v) => v.m.clientMsgID == msg.m.clientMsgID);
    }
  }

  void onAvatarTap(UserInfo userInfo) {}

  void onAvatarLongPress(UserInfo userInfo) {}

  /// 消息撤回
  void revokeMessage(MessageExt message) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.messageManager.revokeMessage(conversationID: conversationInfo.value.conversationID, clientMsgID: message.m.clientMsgID!);
    });
  }

  void onGroupBothMessageDelete(MessageExt extMsg) {}

  void onMoreSelectShare() {}

  void onMoreSelectDelete() {}

  @override
  void onNewRecvMessageRevoked(RevokedInfo info) {
    MessageExt? extMsg = data.firstWhereOrNull((v) => v.m.clientMsgID == info.clientMsgID);
    if (extMsg != null) {
      extMsg.m.contentType = MessageType.revokeMessageNotification;
      updateMessage(extMsg);
    }
  }

  /// 重新发送
  void onResend(MessageExt message) async {
    try {
      message.m.status = MessageStatus.sending;
      await updateMessage(message);
      message = await sendMessage(message);

      updateMessage(message);
    } catch (e) {
      /// 发送失败 修改状态
      message.m.status = MessageStatus.failed;
      updateMessage(message);
    }
  }

  /// 开始计时
  void startTimer(MessageExt extMsg) {
    if (extMsg.ext.isPrivateChat) {
      extMsg.ext.timer?.cancel();
      int seconds = (extMsg.m.attachedInfoElem?.burnDuration == 0 ? 30 : Utils.getValue(extMsg.m.attachedInfoElem?.burnDuration, extMsg.ext.seconds));
      extMsg.ext.timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (seconds == 0) {
          t.cancel();
          onTimerEnd(extMsg);
          return;
        }
        seconds -= 1;
        extMsg.ext.seconds = seconds;
        updateMessage(extMsg);
        if (seconds == 0) {
          t.cancel();
          onTimerEnd(extMsg);
        }
      });
    }
  }

  Future<void> onTimerEnd(MessageExt extMsg) async {
    data.removeWhere((v) => v.m.clientMsgID == extMsg.m.clientMsgID);
    await OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(message: extMsg.m);
  }

  void onPointerRightDown(PointerDownEvent event, MessageExt extMsg) {}

  /// 复制文本
  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// 删除消息
  Future<void> deleteMessage(MessageExt extMsg) async {
    Utils.exceptionCapture(() async {
      data.removeWhere((v) => v.m.clientMsgID == extMsg.m.clientMsgID);
      await OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(message: extMsg.m);
    });
  }

  Widget contextMenuBuilder(BuildContext context, MessageExt extMsg, EditableTextState state) {
    return Container();
  }

  /// 移至黑名单
  void onMoveToBlackList() {
    if (uID == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.friendshipManager.addBlack(userID: uID!);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value.conversationID);
    });
  }

  /// 移出黑名单
  void onRemoveFromBlackList() {
    if (uID == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.friendshipManager.removeBlack(userID: uID!);
    });
  }
}
