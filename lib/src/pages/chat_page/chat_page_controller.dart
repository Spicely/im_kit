part of '../../../im_kit.dart';

enum ImChatPageFieldType {
  voice,
  emoji,
  actions,
  none,
}

enum SheetType {
  /// 文件
  file,

  /// 无
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

class ChatAttachment {
  /// 是否隐藏
  final bool isHidden;

  final File file;

  final Uint8List? memory;

  ChatAttachment({required this.isHidden, required this.file, this.memory});
}

class ChatPageController extends GetxController with OpenIMListener, GetTickerProviderStateMixin, WindowListener, ImKitListen {
  final MenuController menuController = MenuController();

  final MenuController emojiMenuController = MenuController();

  final FocusNode editFocusNode = FocusNode();

  late Rx<ConversationInfo?> conversationInfo;

  late RxList<MessageExt> data;

  late TabController tabController;

  RxList<ChatPageItem> tabs = RxList([]);

  RxBool isDrop = false.obs;

  /// sheet类型
  Rx<SheetType> sheetType = SheetType.none.obs;

  /// 群成员信息
  RxList<GroupMembersInfo> groupMembers = RxList([]);

  /// 群信息
  Rx<GroupInfo?> groupInfo = Rx(null);

  final FcNativeVideoThumbnail fcNativeVideoThumbnail = FcNativeVideoThumbnail();

  final bool isInit;

  int loadNum = 40;

  /// 自己的信息
  UserInfo get uInfo => OpenIM.iMManager.uInfo!;

  /// 私聊用户信息
  Rx<FullUserInfo?> chatUserInfo = Rx(null);

  RxInt currentIndex = (-1).obs;

  final TextEditingController textEditingController = TextEditingController();

  final u.FlyoutController flyoutController = u.FlyoutController();

  /// 自己在群里的信息
  GroupMembersInfo? get gInfo => (isGroupChat && groupMembers.isNotEmpty) ? groupMembers.firstWhere((v) => v.userID == uInfo.userID) : null;

  /// 是否是管理员
  bool get isAdmin => gInfo?.roleLevel == GroupRoleLevel.admin;

  /// 是否是群成员
  bool get isMember => gInfo?.roleLevel == GroupRoleLevel.member;

  /// 是否是群主
  bool get isOwner => gInfo?.roleLevel == GroupRoleLevel.owner;

  /// 附件信息
  RxList<ChatAttachment> attachments = RxList<ChatAttachment>([]);

  /// 多选
  RxBool showSelect = false.obs;

  /// 是否能管理群
  bool get isCanAdmin => gInfo?.roleLevel != GroupRoleLevel.member;

  /// 是否能发言
  bool get isCanSpeak => !isMuteUser.value || !isMute.value || isCanAdmin;

  /// 不允许通过群获取成员资料
  bool get lookMemberInfo => isSingleChat ? false : groupInfo.value?.lookMemberInfo == 1;

  /// 群id
  String? get gId => Utils.getValue<String?>(conversationInfo.value?.groupID, null);

  /// 用户id
  String? get uId => Utils.getValue<String?>(conversationInfo.value?.userID, null);

  /// 引用消息
  Rx<MessageExt?> quoteMessage = Rx(null);

  /// 选中的消息列表
  RxList<MessageExt> selectList = RxList([]);

  OverlayEntry? overlayEntry;

  String get title {
    if (isGroupChat) {
      return '${conversationInfo.value?.showName}(${groupMembers.length})';
    } else {
      try {
        Map<String, dynamic> map = jsonDecode(conversationInfo.value?.showName ?? '{}');
        return Utils.getValue(map['remark'], map['nickname']) ?? '';
      } catch (e) {
        return conversationInfo.value?.showName ?? '';
      }
    }
  }

  ChatPageController({
    required List<MessageExt> messages,
    ConversationInfo? conversation,
    this.isInit = true,
  }) {
    data = RxList(messages.reversed.toList());
    if (data.length < loadNum && isInit) {
      noMore.value = true;
      // Utils.exceptionCapture(() async {
      //   MessageExt encryptedNotification = await Message(
      //     contentType: MessageType.encryptedNotification,
      //     createTime: data.isEmpty ? DateTime.now().millisecondsSinceEpoch : data.last.m.createTime,
      //   ).toExt();
      //   data.add(encryptedNotification);
      // });
    }
    conversationInfo = Rx(conversation);
  }
  ScrollController scrollController = ScrollController();

  /// 聊天对象id
  String? get userID => conversationInfo.value?.userID;

  String? get groupID => conversationInfo.value?.groupID;

  /// 是单聊
  bool get isSingleChat => conversationInfo.value?.isSingleChat ?? false;

  /// 是群聊
  bool get isGroupChat => conversationInfo.value?.isGroupChat ?? false;

  /// 是否有输入内容
  RxBool hasInput = false.obs;

  Rx<ImChatPageFieldType> fieldType = ImChatPageFieldType.none.obs;

  RxBool noMore = false.obs;

  final FocusNode focusNode = FocusNode();

  /// 窗口是否焦距
  bool isFocus = true;

  /// 是否全体禁言
  RxBool isMute = false.obs;

  /// 记录输入框的历史记录
  String historyText = '';

  /// 是否个人禁言
  RxBool isMuteUser = false.obs;

  final List<int> _types = [1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1514, 1515, 1201, 1202, 1203, 1204, 1205, 27, 77, 1512, 1513, 2023, 2024, 2025, 1701];

  /// at用户映射表
  RxList<AtUserInfo> atUserMap = RxList<AtUserInfo>([]);

  final ITextEditingController search = ITextEditingController();

  /// 显示全部群成员
  final RxBool showAllGroupMembers = false.obs;

  /// 显示群成员
  final RxList<GroupMembersInfo> showGroupMembers = <GroupMembersInfo>[].obs;

  /// 图片选中信息
  RxList<PhotoManagerPaths> selectPhotos = RxList<PhotoManagerPaths>([]);

  @override
  void onWindowFocus() {
    isFocus = true;
    markMessageAsRead(data);
  }

  @override
  void onWindowBlur() {
    isFocus = false;
  }

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    windowManager.addListener(this);
    ImKitIsolateManager.addListener(this);
    textEditingController.addListener(_checkHistoryAction);

    textEditingController.removeListener(_checkHistoryAction);
    ImCore.onPlayerStateChanged(onPlayerStateChanged);
    super.onInit();

    tabController = TabController(length: 1 + tabs.length, vsync: this);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        fieldType.value = ImChatPageFieldType.none;
      }
    });
    search.addListener(() {
      if (search.text.isEmpty) {
        if (showAllGroupMembers.value) {
          showGroupMembers.value = groupMembers;
        } else {
          /// 只显示前6个
          showGroupMembers.value = groupMembers.where((v) => v.nickname!.contains(search.text)).take(6).toList();
        }
      } else {
        if (showAllGroupMembers.value) {
          showGroupMembers.value = groupMembers.where((v) => v.nickname!.contains(search.text)).toList();
        } else {
          /// 只显示前6个
          showGroupMembers.value = groupMembers.where((v) => v.nickname!.contains(search.text)).take(6).toList();
        }
      }
    });
    computeTime();

    /// 下载文件
    for (var v in data) {
      downFile(v);

      startTimer(v);
    }
  }

  @override
  void onReady() {
    textEditingController.addListener(_checkHistoryAction);
    super.onReady();
    if (isInit) {
      getData();
      scrollController.addListener(() {
        if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 40) {
          onLoad();
        }
      });
    }

    if (Utils.isNotEmpty(conversationInfo.value?.draftText)) {
      textEditingController.text = conversationInfo.value?.draftText ?? '';
      if (textEditingController.text.contains('@-1#所有人')) {
        atUserMap.add(const AtUserInfo(atUserID: '-1', groupNickname: '所有人'));
      }
    }
  }

  @override
  void onConversationChanged(List<ConversationInfo> list) {
    for (var v in list) {
      if (v.conversationID == conversationInfo.value?.conversationID) {
        conversationInfo.value = v;
        conversationInfo.refresh();
      }
    }
  }

  /// 设置阅后即焚
  Future<void> setOneConversationPrivateChat(bool status) async {
    try {
      conversationInfo.value?.isPrivateChat = status;
      conversationInfo.refresh();
      if (conversationInfo.value != null) {
        await OpenIM.iMManager.conversationManager.setOneConversationPrivateChat(
          conversationID: conversationInfo.value!.conversationID,
          isPrivate: status,
        );
      }
    } catch (e) {
      conversationInfo.value?.isPrivateChat = !status;
      conversationInfo.refresh();
      MukaConfig.config.exceptionCapture.error(e);
    }
  }

  // /// 已从黑名单移除
  // @override
  // void onBlacklistDeleted(BlacklistInfo u) {
  //   if (u.userID == chatUserInfo.value?.userID) {
  //     chatUserInfo.value?.isBlacklist = false;
  //   }
  // }

  /// 设置黑名单
  Future<void> setBlackStatus(bool status) async {
    // try {
    //   chatUserInfo.value?.isBlacklist = status;
    //   chatUserInfo.refresh();
    //   if (status) {
    //     await OpenIM.iMManager.friendshipManager.addBlacklist(uid: userID!);
    //   } else {
    //     await OpenIM.iMManager.friendshipManager.removeBlacklist(uid: userID!);
    //   }
    // } catch (e) {
    //   chatUserInfo.value?.isBlacklist = !status;
    //   chatUserInfo.refresh();
    //   MukaConfig.config.exceptionCapture.error(e);
    // }
  }

  @override
  void onProgress(String clientMsgID, dynamic progress) {
    int index = data.indexWhere((v) => v.m.clientMsgID == clientMsgID);
    if (index != -1) {
      data[index].ext.progress = progress / 100;
      data[index].m.status = MessageStatus.succeeded;
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

  Future<void> onKeyEvent(RawKeyEvent event) async {
    if (!isCanSpeak) return;

    /// shift + enter 换行
    if (event is RawKeyDownEvent && event.isShiftPressed && event.logicalKey == LogicalKeyboardKey.enter) {
      return;
    }
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      await onSendMessage();
      textEditingController.clear();
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
          _copyClipboardToMemory();
        }
      } else {
        /// 监听粘贴按键组合
        if (event.logicalKey == LogicalKeyboardKey.keyV && event.isControlPressed) {
          _copyClipboardToMemory();
        }
      }
    }
  }

  /// 自定义表情发送
  Future<void> onDiyEmojiSend(Emoji emoji, int index, String locPath) async {
    MessageExt? extMsg;
    try {
      /// 获取网址
      Uri url = Uri.parse(emoji.sampleDiagramUrl!);
      String path = '${emoji.emoticonsId}/${emoji.emojiList![index].name}';
      Message newMsg = await OpenIM.iMManager.messageManager.createCustomMessage(
        data: jsonEncode({
          'emoticons_id': emoji.emoticonsId,
          'emoticons_name': emoji.name,
          'file_path': path,
          'url': '${url.origin}/emoticons/$path',
          'w': emoji.emojiList![index].w,
          'h': emoji.emojiList![index].h,
        }),
        extension: '',
        description: '',
      );

      newMsg.contentType = 300;
      newMsg.pictureElem = PictureElem(sourcePath: locPath);

      extMsg = await newMsg.toExt();
      extMsg.ext.file = File(locPath);
      data.insert(0, extMsg);
      extMsg = await sendMessageNotOss(extMsg);
      extMsg.m.pictureElem = PictureElem(sourcePath: locPath);
      updateMessage(extMsg);
    } catch (e) {
      if (extMsg != null) {
        /// 发送失败 修改状态
        extMsg.m.status = MessageStatus.failed;
        updateMessage(extMsg);
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

  // 存储附件信息
  void _copyClipboardToMemory() {
    Utils.exceptionCapture(() async {
      Uint8List? imageBytes = await Pasteboard.image;
      if (imageBytes != null) {
        ChatAttachment? chatAttachment = attachments.firstWhereOrNull((v) => v.memory == imageBytes);
        if (chatAttachment == null) {
          String path = await ImKitIsolateManager.saveBytesToTemp(imageBytes);
          attachments.add(ChatAttachment(isHidden: false, file: File(path), memory: imageBytes));
        } else {
          attachments.add(chatAttachment);
        }
      }
    });
  }

  void onAtDeleteCallback(String id) {
    atUserMap.removeWhere((v) => v.atUserID == id);
  }

  void getData() {
    Utils.exceptionCapture(() async {
      /// 下载文件
      for (var v in data) {
        downFile(v);
        startTimer(v);
      }
      if (isGroupChat) {
        groupInfo.value = (await OpenIM.iMManager.groupManager.getGroupsInfo(groupIDList: [groupID!])).first;

        groupMembers.value = await OpenIM.iMManager.groupManager.getGroupMemberList(groupId: groupID!);
        if (groupInfo.value?.status == 3) {
          isMute.value = true;
          if (conversationInfo.value?.draftText != null) {
            String draftText = conversationInfo.value?.draftText ?? '';

            /// 使用正则匹配 例子 @1231#cc @qeq#大区 输出 [1231,qeq]
            var regexAt = groupMembers.map((e) => '@${e.userID} ').toList().join('|');
            draftText.splitMapJoin(
              RegExp(regexAt),
              onMatch: (Match m) {
                String value = m.group(0)!;
                String id = value.split('#').first.replaceFirst('@', '').trim();
                for (var i in groupMembers) {
                  if (i.userID == id) {
                    addAtUserMap(AtUserInfo(atUserID: id, groupNickname: i.nickname));
                    break;
                  }
                }
                return '';
              },
            );
          }
          isMuteUser.value = userIsMuted(gInfo?.muteEndTime ?? 0);

          /// 依据管理员排序
          groupMembers.sort((a, b) {
            if (a.roleLevel == GroupRoleLevel.owner) {
              return -1;
            } else if (b.roleLevel == GroupRoleLevel.owner) {
              return 1;
            } else if (a.roleLevel == GroupRoleLevel.admin) {
              return -1;
            } else if (b.roleLevel == GroupRoleLevel.admin) {
              return 1;
            } else {
              return 0;
            }
          });
          showGroupMembers.value = groupMembers.take(6).toList();
        } else {
          if (userID == null || OpenIM.iMManager.uid == userID) return;
          chatUserInfo.value = (await OpenIM.iMManager.friendshipManager.getFriendsList(userIDList: [userID!])).first;
        }
      }
      markMessageAsRead(data);
    });
  }

  void _checkHistoryAction() {
    hasInput.value = textEditingController.text.isNotEmpty;
    if (textEditingController.text.length == historyText.length + 1 && isGroupChat) {
      /// 获取光标位置
      int index = textEditingController.selection.baseOffset;

      /// 光标前一个字符 == @
      if (textEditingController.text[index - 1] == '@') {
        onAtTriggerCallback();
      }
    }

    /// 判断是不是只少了一个@

    if ('${textEditingController.text}@' == historyText && isGroupChat) {
      onCancelAt();
    }

    if (textEditingController.text.isNotEmpty || textEditingController.text.trim().isNotEmpty) {
      /// 对比历史记录 当输入内容比历史记录少@10004467 10004467为userID时触发删除@事件
      if (historyText.length > textEditingController.text.length && isGroupChat) {
        for (var key in atUserMap) {
          AtUserInfo? v = key;

          if (!textEditingController.text.contains('@${v.atUserID} ')) {
            /// 跳出循环
            onAtDeleteCallback(key.atUserID!);
            break;
          }
        }
      }
    }
    historyText = textEditingController.text;
  }

  /// 取消@
  void onCancelAt() {}

  /// 标记已读消息
  Future<void> markMessageAsRead(List<MessageExt> messages) async {
    if (Utils.isDesktop && !isFocus) return;
    if (messages.isEmpty) return;
    List<MessageExt> msgs = [...messages];

    /// 忽略通知类消息
    List<int> types = [1501, 1502, 1503, 1504, 1505, 1506, 1507, 1508, 1509, 1510, 1511, 1514, 1515, 1201, 1202, 1203, 1204, 1205, 27, 77, 1701, 1512, 1513, 2023, 2024, 2025];
    types.removeWhere((v) => v == 1701);
    msgs.removeWhere((v) => types.contains(v.m.contentType) || v.m.sendID == uInfo.userID || v.m.isRead == true);
    List<String> ids = msgs.map((e) => e.m.clientMsgID!).toList();
    if (ids.isEmpty) return;

    /// 群会话
    if (conversationInfo.value != null) {
      try {
        OpenIM.iMManager.messageManager.markMessageAsReadByMsgID(conversationID: conversationInfo.value!.conversationID, messageIDList: ids);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  /// @触发事件
  void onAtTriggerCallback() async {}

  void addAtUserMap(AtUserInfo info) {
    int index = atUserMap.indexWhere((v) => v.atUserID == info.atUserID);
    if (index == -1) {
      atUserMap.add(info);
    }
  }

  /// 双击打开文件目录
  void onDoubleTapFile(MessageExt extMsg) {
    if (extMsg.ext.progress != null) return;
    if (Utils.isDesktop) {
      if (extMsg.ext.file != null) {
        Uri fileUri = Uri.file(extMsg.ext.file!.path);
        launchUrl(fileUri);
      } else {
        // OpenIM.iMManager.messageManager.downloadFileReturnPaths(message: extMsg.m).then((paths) {
        //   extMsg.ext.file = File(paths.first);
        //   Uri fileUri = Uri.file(extMsg.ext.file!.path);
        //   launchUrl(fileUri);
        // }).catchError((e) {
        //   extMsg.ext.errorCode = ImExtErrorCode.downloadFailure;
        //   updateMessage(extMsg);
        // });
      }
    }
  }

  void saveFile(MessageExt extMsg) {
    Utils.exceptionCapture(() async {
      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      bool status = await ImKitIsolateManager.saveFileToAlbum(extMsg.ext.file!.path, fileName: basenameWithoutExtension(extMsg.m.videoElem?.videoUrl ?? extMsg.m.fileElem?.fileName ?? extMsg.m.pictureElem?.sourcePicture?.url ?? ''));
    }, error: (e) {
      // onError?.call(e);
    });
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
    windowManager.removeListener(this);
    ImKitIsolateManager.removeListener(this);
    _removeOverlay();
    textEditingController.removeListener(_checkHistoryAction);
    for (var i in data) {
      if (i.ext.isPrivateChat && i.m.isRead!) {
        OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(message: i.m);
      }
    }

    /// 设置草稿
    if (conversationInfo.value != null && textEditingController.text.trim().isNotEmpty) {
      OpenIM.iMManager.conversationManager.setConversationDraft(
        conversationID: conversationInfo.value!.conversationID,
        draftText: textEditingController.text,
      );
    }

    /// 清空草稿
    if (conversationInfo.value != null && Utils.isNotEmpty(conversationInfo.value?.draftText) && textEditingController.text.isEmpty) {
      OpenIM.iMManager.conversationManager.setConversationDraft(
        conversationID: conversationInfo.value!.conversationID,
        draftText: '',
      );
    }

    super.onClose();
  }

  @override
  void onRecvNewMessage(Message msg) async {
    String? id = Utils.getValue(msg.groupID, msg.sendID);
    MessageExt extMsg = await msg.toExt();
    if (id == userID || id == groupID || userID == extMsg.m.recvID) {
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
    }
    if (conversationInfo.value != null && extMsg.ext.isBothDelete) {
      OpenIM.iMManager.conversationManager.getOneConversation(sourceID: Utils.getValue(msg.groupID, msg.sendID == OpenIM.iMManager.uid ? msg.recvID : msg.sendID)!, sessionType: msg.groupID == null ? ConversationType.single : ConversationType.group).then((c) {
        if (c.conversationID == conversationInfo.value!.conversationID) {
          doubleCleanMessage(extMsg);
        }
      });
    }
  }

  void downFile(MessageExt extMsg) async {
    String saveDir = ImCore.userDir(conversationInfo.value!.conversationID);
    // if (MessageTypeExtend.customDiyEmoji == extMsg.m.contentType) {
    //   Map<String, dynamic> map = jsonDecode(extMsg.m.content ?? '{}');
    //   map = jsonDecode(map['data'] ?? '{}');
    //   IsolateManager.getEmojiUrl(map).then((v) {
    //     if (v != null) {
    //       message.file = File(v);

    //       /// 更新消息
    //       updateMessage(message);
    //     }
    //   });
    //   return;
    // }
    if (extMsg.m.clientMsgID == null) return;
    if (conversationInfo.value != null && [MessageType.picture, MessageType.video, MessageType.voice, MessageType.file].contains(extMsg.m.contentType)) {
      ImKitIsolateManager.downloadFiles(
        extMsg.m.clientMsgID!,
        [
          DownloadItem(
            url: extMsg.m.fileElem?.sourceUrl ?? extMsg.m.videoElem?.snapshotUrl ?? extMsg.m.pictureElem?.sourcePicture?.url ?? extMsg.m.soundElem?.sourceUrl ?? '',
            saveDir: saveDir,
          ),
          if (extMsg.m.videoElem?.videoUrl != null)
            DownloadItem(
              url: extMsg.m.videoElem!.videoUrl!,
              saveDir: saveDir,
            ),
        ],
      );
      extMsg.ext.isDownloading = true;
      updateMessage(extMsg);
    } else if (MessageType.quote == extMsg.m.contentType) {
      if (conversationInfo.value != null && [MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.quoteElem?.quoteMessage?.contentType)) {
        ImKitIsolateManager.downloadFiles(
          extMsg.m.clientMsgID!,
          [
            DownloadItem(
              url: extMsg.m.fileElem?.sourceUrl ?? extMsg.m.videoElem?.snapshotUrl ?? extMsg.m.pictureElem?.sourcePicture?.url ?? extMsg.m.soundElem?.sourceUrl ?? '',
              saveDir: saveDir,
            ),
            if (extMsg.m.videoElem?.videoUrl != null)
              DownloadItem(
                url: extMsg.m.videoElem!.videoUrl!,
                saveDir: saveDir,
              ),
          ],
        );
      }
      extMsg.ext.isDownloading = true;
      updateMessage(extMsg);
    }
  }

  /// 下载进度
  @override
  void onDownloadProgress(String id, double progress) {
    MessageExt? extMsg = data.firstWhereOrNull((v) => v.m.clientMsgID == id);
    if (extMsg == null) return;
    extMsg.ext.progress = progress;
    updateMessage(extMsg);
  }

  /// 下载失败
  @override
  void onDownloadFailure(String id, String error) {}

  /// 下载成功
  @override
  void onDownloadSuccess(String id, List<String> paths) {
    MessageExt? extMsg = data.firstWhereOrNull((v) => v.m.clientMsgID == id);
    if (extMsg == null) return;
    if (paths.length == 2) {
      extMsg.ext.previewFile ??= File(paths.first);
      extMsg.ext.file ??= File(paths.last);
    } else {
      extMsg.ext.file ??= File(paths.first);
    }
    extMsg.ext.isDownloading = false;
    updateMessage(extMsg);
  }

  @override
  void onGroupMemberInfoChanged(GroupMembersInfo info) {
    if (isGroupChat && groupMembers.isNotEmpty) {
      if (info.userID == uInfo.userID) {
        updateGroupMemberInfo(info);
      } else {
        /// 更新群成员信息
        int index = groupMembers.indexWhere((v) => v.userID == info.userID);
        int i = showGroupMembers.indexWhere((v) => v.userID == info.userID);
        if (index != -1) {
          groupMembers[index] = info;
          groupMembers.refresh();
        }
        if (i != -1) {
          showGroupMembers[i] = info;
          groupMembers.refresh();
        }
      }
    }
  }

  @override
  void onGroupMemberDeleted(GroupMembersInfo info) {
    groupMembers.removeWhere((v) => v.userID == info.userID);
    showGroupMembers.removeWhere((element) => element.userID == info.userID);
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

  /// 保存群设置
  void setGroupInfo({String? groupName, String? notification, String? introduction, String? faceUrl, String? ex, Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.setGroupInfo(
        groupID: gId!,
        introduction: introduction,
        notification: notification,
        faceUrl: faceUrl,
        groupName: groupName,
        ex: ex,
      );
      onSuccess?.call();
      if (groupName != null) groupInfo.value?.groupName = groupName;
      if (notification != null) groupInfo.value?.notification = notification;
      if (introduction != null) groupInfo.value?.introduction = introduction;
      if (faceUrl != null) groupInfo.value?.faceURL = faceUrl;
      if (ex != null) groupInfo.value?.ex = ex;
      groupInfo.refresh();
    });
  }

  /// 设置群成员管理员
  void setGroupMemberRoleLevel({required String userID, required int roleLevel, Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.setGroupMemberRoleLevel(
        groupID: gId!,
        userID: userID,
        roleLevel: roleLevel,
      );
      onSuccess?.call();
      int index = groupMembers.indexWhere((v) => v.userID == userID);
      if (index != -1) {
        groupMembers[index].roleLevel = roleLevel;
        groupMembers.refresh();
      }
    });
  }

  /// 禁言用户
  void setGroupMemberMute({required String userID, required int seconds, Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.changeGroupMemberMute(
        groupID: gId!,
        userID: userID,
        seconds: seconds,
      );
      onSuccess?.call();
      int index = groupMembers.indexWhere((v) => v.userID == userID);
      if (index != -1) {
        groupMembers[index].muteEndTime = seconds;
        groupMembers.refresh();
      }
    });
  }

  @override
  void onNewRecvMessageRevoked(RevokedInfo info) {
    MessageExt? extMsg = data.firstWhereOrNull((v) => v.m.clientMsgID == info.clientMsgID);
    if (extMsg != null) {
      extMsg.m.contentType = MessageType.revokeMessageNotification;
      updateMessage(extMsg);
    }
  }

  /// 结束拖动文件
  void onDragExited(DropEventDetails detail) {
    isDrop.value = false;
  }

  /// 开始拖动文件
  void onDragEntered(DropEventDetails detail) {
    isDrop.value = true;
  }

  /// 文件拖动完成
  void onDragDone(DropDoneDetails detail) {
    Utils.exceptionCapture(() async {
      final files = detail.files;
      for (var file in files) {
        /// 获取后缀名
        String suffix = file.path.split('.').last.toLowerCase();
        String? dest;

        Message msg;

        /// 判断是不是图片
        if (['png', 'jpg', 'jpeg', 'gif'].contains(suffix)) {
          msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path);
        }

        /// 判断视频
        else if (['mp4', 'avi', '3gp', 'mkv'].contains(suffix)) {
          dest = join(ImCore.tempPath, '${const Uuid().v4()}.$suffix');
          await fcNativeVideoThumbnail.getVideoThumbnail(srcFile: file.path, destFile: dest, width: 300, height: 600, format: 'jpeg', quality: 90);
          msg = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(videoPath: file.path, videoType: suffix, duration: 0, snapshotPath: dest);
        } else {
          msg = await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(filePath: file.path, fileName: file.name);
        }
        // if (getIntValue(msg.fileElem?.fileSize, msg.videoElem?.videoSize, msg.pictureElem?.sourcePicture?.size, msg.soundElem?.dataSize) == 0) {
        //   MukaConfig.config.exceptionCapture.error(OpenIMError(0, '不能发送空文件'));
        //   return;
        // }

        MessageExt extMsg = await msg.toExt();
        extMsg.ext.file = File(file.path);
        if (dest != null) {
          extMsg.ext.previewFile = File(dest);
        }
        data.insert(0, extMsg);
        sendMessage(extMsg);
      }
    });
  }

  @override
  void onGroupInfoChanged(GroupInfo info) {
    if (groupInfo.value == null) return;
    groupInfo.update((val) {
      val?.needVerification = info.needVerification;
      val?.notificationUpdateTime = info.notificationUpdateTime;
      val?.notificationUserID = info.notificationUserID;
      val?.introduction = info.introduction;
      val?.notification = info.notification;
      val?.groupName = info.groupName;
      val?.groupType = info.groupType;
      val?.groupID = info.groupID;
      val?.faceURL = info.faceURL;
      val?.lookMemberInfo = info.lookMemberInfo;
      val?.status = info.status;
      val?.createTime = info.createTime;
      val?.ex = info.ex;
    });
    if (info.status == 3) {
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

  void onQuoteMessageTap(MessageExt msgExt) {
    // Utils.exceptionCapture(() async {
    //   int index = data.indexWhere((v) => v.m.clientMsgID == msgExt.ext.quoteMessage?.m.clientMsgID);
    //   if (index != -1) {
    //     currentIndex.value = index;
    //     itemScrollController.jumpTo(index: index);
    //   } else {
    //     AdvancedMessage result = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
    //       conversationID: conversationInfo.value?.conversationID,
    //       startMsg: msgExt.m,
    //     );
    //     List<MessageExt> newExts = (await Future.wait(result.messageList.map((e) => e.toExt()))).reversed.toList();

    //     /// 移除已经有了的数据
    //     newExts.removeWhere((v) => data.indexWhere((e) => e.m.clientMsgID == v.m.clientMsgID) != -1);
    //     for (var v in newExts) {
    //       downFile(v);
    //     }
    //     data.addAll(newExts);
    //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //       int index = data.indexWhere((v) => v.m.clientMsgID == msgExt.ext.quoteMessage?.m.clientMsgID);
    //       if (index != -1) {
    //         currentIndex.value = index;
    //         itemScrollController.jumpTo(index: index);
    //       }
    //     });

    // //     itemScrollController.jumpTo(index: data.length);
    // //   }

    // //   /// 2s 后清除引用消息
    // //   Future.delayed(const Duration(seconds: 2), () {
    // //     currentIndex.value = -1;
    // //   });
    // // });
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
      if (_check2TimeGap(message.m.sendTime ?? message.m.createTime ?? 0, lastMessage.m.sendTime ?? lastMessage.m.createTime!)) {
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
      MessageExt? quoteMessage = data[index].ext.quoteMessage;

      data[index] = ext;
      data[index].ext.quoteMessage = quoteMessage;
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
      Utils.exceptionCapture(() async {
        for (var file in result.files) {
          if (file.path != null) {
            Message msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path!);
            MessageExt extMsg = await msg.toExt();
            extMsg.ext.file = File(file.path!);
            data.insert(0, extMsg);
            sendMessage(extMsg);
          }
        }
      });
    }
  }

  int getIntValue(
    int? value, [
    int? defValue1,
    int? defValue2,
    int? defValue3,
    int? defValue4,
    int? defValue5,
    int? defValue6,
  ]) {
    List<int?> defValues = [value, defValue1, defValue2, defValue3, defValue4, defValue5, defValue6];
    int? defValue = defValues.firstWhere((v) => v != null && v != 0, orElse: () => null);
    return defValue ?? 0;
  }

  /// 发送文件
  Future<void> onSendFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          /// 获取后缀名
          String? suffix = file.extension?.toLowerCase();
          String? dest;

          Message msg;

          /// 判断是不是图片
          if (['png', 'jpg', 'jpeg', 'gif'].contains(suffix)) {
            msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: file.path!);
          }

          /// 判断视频
          else if (['mp4', 'avi', '3gp', 'mkv'].contains(suffix)) {
            dest = join(ImCore.tempPath, '${const Uuid().v4()}.$suffix');
            await fcNativeVideoThumbnail.getVideoThumbnail(srcFile: file.path!, destFile: dest, width: 300, height: 600, format: 'jpeg', quality: 90);
            msg = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(videoPath: file.path!, videoType: suffix!, duration: 0, snapshotPath: dest);
          } else {
            msg = await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(filePath: file.path!, fileName: file.name);
          }
          // if (getIntValue(msg.fileElem?.fileSize, msg.videoElem?.videoSize, msg.pictureElem?.sourcePicture?.size, msg.soundElem?.dataSize) == 0) {
          //   MukaConfig.config.exceptionCapture.error(OpenIMError(0, '不能发送空文件'));
          //   return;
          // }
          MessageExt extMsg = await msg.toExt();
          extMsg.ext.file = File(file.path!);
          if (dest != null) {
            extMsg.ext.previewFile = File(dest);
          }
          data.insert(0, extMsg);
          sendMessage(extMsg);
        }
      }
    }
  }

  void onAvatarRightTap(Offset position, String userID) {}

  /// 下载文件
  void onTapDownFile(MessageExt extMsg) {
    downFile(extMsg);
  }

  /// 点击播放视频
  void onTapPlayVideo(MessageExt extMsg) {
    if (extMsg.ext.file == null) return;
    Get.to(() => ImPlayer(message: extMsg));
  }

  /// 点击图片
  void onPictureTap(MessageExt extMsg) {
    if (extMsg.ext.file == null) return;

    /// 获取所有图片
    List<MessageExt> messages = data.where((v) => v.m.contentType == MessageType.picture).toList();
    Get.to(
      () => ImPreview(messages: messages.reversed.toList(), currentMessage: extMsg),
      transition: Transition.fadeIn,
    );
  }

  /// 设置草稿
  void setConversationDraft(String draft) {
    if (conversationInfo.value == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.setConversationDraft(
        conversationID: conversationInfo.value!.conversationID,
        draftText: draft,
      );
    });
  }

  /// 合并消息点击事件
  void onMergerTap(MessageExt extMsg) {
    Utils.exceptionCapture(() async {
      List<MessageExt> messages = await Future.wait((extMsg.m.mergeElem?.multiMessage ?? []).map((e) => e.toExt()).toList());
      ChatPageController chatPageController = ChatPageController(messages: messages.reversed.toList());
      Get.to(() => ChatPage(controller: chatPageController));
    });
  }

  /// 发送消息不上传到OSS
  Future<MessageExt> sendMessageNotOss(MessageExt msg, {String? userId, String? groupId}) async {
    if (conversationInfo.value != null && Utils.isNotEmpty(conversationInfo.value?.draftText)) {
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
      u_id = uId;
      g_id = gId;
    }
    try {
      Message newMsg = await OpenIM.iMManager.messageManager.sendMessageNotOss(
        message: msg.m,
        userID: u_id,
        groupID: g_id,
        offlinePushInfo: OfflinePushInfo(title: '新的未读消息'),
      );
      MessageExt extMsg = await newMsg.toExt();
      extMsg.m.status = MessageStatus.succeeded;
      updateMessage(extMsg);
      downFile(extMsg);
      return extMsg;
    } catch (e) {
      msg.m.status = MessageStatus.failed;
      updateMessage(msg);
      if (e is OpenIMError) {
        onSendMessageFailed(e.code);
      }
      return msg;
    }
  }

  /// 发送消息统一入口
  Future<MessageExt> sendMessage(
    MessageExt msg, {
    String? userId,
    String? groupId,
    String? text,
  }) async {
    if (conversationInfo.value != null && Utils.isNotEmpty(conversationInfo.value?.draftText)) {
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
      u_id = uId;
      g_id = gId;
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
      if ([MessageType.atText, MessageType.text].contains(msg.m.contentType)) {
        newMsg.textElem?.content = text;
        newMsg.atTextElem?.text = text;
        newMsg.quoteElem?.text = text;
      }
      MessageExt extMsg = await newMsg.toExt();
      updateMessage(extMsg);
      downFile(extMsg);
      return extMsg;
    } catch (e) {
      msg.m.status = MessageStatus.failed;
      updateMessage(msg);
      if (e is OpenIMError) {
        onSendMessageFailed(e.code);
      }
      return msg;
    }
  }

  Future<void> onSendMessageFailed(int errCode) async {
    switch (errCode) {
      case 600:
        Message customMessage = await OpenIM.iMManager.messageManager.createCustomMessage(data: jsonEncode({'contentType': 2025}), extension: 'notFriend', description: 'notFriend');
        Message msg = await OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(message: customMessage, senderID: OpenIM.iMManager.uid, receiverID: conversationInfo.value?.userID);
        data.insert(0, await msg.toExt());
        break;
      case 601:
        Message customMessage = await OpenIM.iMManager.messageManager.createCustomMessage(data: jsonEncode({'contentType': 2024}), extension: 'inBlacklist', description: 'inBlacklist');
        Message msg = await OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(message: customMessage, senderID: OpenIM.iMManager.uid, receiverID: conversationInfo.value?.userID);
        data.insert(0, await msg.toExt());
        break;
      default:
    }
  }

  /// 更新自己在群里的信息
  void updateGroupMemberInfo(GroupMembersInfo info) {
    if (isGroupChat) {
      int index = groupMembers.indexWhere((v) => v.userID == info.userID);
      int i = showGroupMembers.indexWhere((v) => v.userID == info.userID);
      if (index != -1) {
        groupMembers[index] = info;
        isMuteUser.value = userIsMuted(gInfo?.muteEndTime ?? 0);
        groupMembers.refresh();
      }
      if (i != -1) {
        showGroupMembers[index] = info;
        showGroupMembers.refresh();
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

  /// 设置群验证
  void setGroupVerification(bool needVerification, {Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      groupInfo.value?.needVerification = needVerification ? 1 : 2;
      groupInfo.refresh();
      await OpenIM.iMManager.groupManager.setGroupVerification(groupID: gId!, needVerification: needVerification ? 1 : 2);
      onSuccess?.call();
    }, error: (e) {
      groupInfo.value?.needVerification = !needVerification ? 1 : 2;
      groupInfo.refresh();
      MukaConfig.config.exceptionCapture.error(e);
    });
  }

  Future<void> changeGroupMute(bool mute) async {
    await OpenIM.iMManager.groupManager.changeGroupMute(groupID: gId!, mute: mute);
  }

  /// 发送消息
  Future<void> onSendMessage() async {
    String value = textEditingController.text;
    if (value.trim().isNotEmpty) {
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
          if (atUserMap.isNotEmpty) {
            message = await createTextAtMessage(atUserMap, value, quoteMessage: quoteMsg?.m);
          } else if (quoteMsg != null) {
            message = await createQuoteMessage(value, quoteMsg.m);
          } else {
            message = await createTextMessage(value);
          }
          quoteMessage.value = null;
          atUserMap.clear();
          data.insert(0, message);

          if (data.length > 5) {
            // itemScrollController.jumpTo(index: 0);
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
    if (selectPhotos.isNotEmpty) {
      Utils.exceptionCapture(() async {
        for (var v in selectPhotos) {
          if (v.imagePath != null) {
            Message msg = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(imagePath: v.imagePath!);
            MessageExt extMsg = await msg.toExt();
            extMsg.ext.file = File(v.imagePath!);
            data.insert(0, extMsg);
            sendMessage(extMsg);
          }
        }
        selectPhotos.clear();
      });
    }
  }

  /// 创建文本消息
  Future<MessageExt> createTextMessage(String val) async {
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

  void onAtTap(TapUpDetails details, String userID) {}

  void onTapPhone(String phone) {
    Uri uri = Uri.parse('tel:$phone');
    launchUrl(uri);
  }

  void onTapEmail(String email) {
    Uri uri = Uri.parse('mailto:$email');
    launchUrl(uri);
  }

  void onForwardMessage(MessageExt extMsg) {}

  Future<void> onLoad() async {
    if (noMore.value) return;
    if (conversationInfo.value == null) return;
    noMore.value = true;
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: conversationInfo.value?.conversationID,
      count: loadNum,
      startMsg: data.last.m,
    );
    List<MessageExt> newExts = await Future.wait(advancedMessage.messageList.reversed.map((e) => e.toExt()));
    data.addAll(newExts);

    if (advancedMessage.messageList.length < loadNum) {
      // MessageExt encryptedNotification = await Message(
      //   contentType: MessageType.encryptedNotification,
      //   createTime: list.isEmpty ? DateTime.now().millisecondsSinceEpoch : data.last.m.createTime,
      // ).toExt();
      // data.add(encryptedNotification);
      noMore.value = true;
    } else {
      noMore.value = false;
    }
    for (var v in newExts) {
      downFile(v);
    }
  }

  void onNotificationUserTap(TapUpDetails details, String userID) {}

  void onCardTap(MessageExt extMsg) {}

  void onLocationTap(MessageExt extMsg) {
    if (Utils.isDesktop) {
      Uri uri = Uri.parse('https://moyozj.net/mapjssdk.html?lat=${extMsg.ext.data['latitude']}&lng=${extMsg.ext.data['longitude']}');
      launchUrl(uri);
    } else {}
  }

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

  void onCopyTip(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void onDeleteMessage(MessageExt extMsg) {}

  /// 设置会话置顶
  Future<void> setPinConversation(bool status, {String? conversationID}) async {
    if (conversationInfo.value == null) return;
    Utils.exceptionCapture(() async {
      try {
        await OpenIM.iMManager.conversationManager.pinConversation(conversationID: conversationID ?? conversationInfo.value!.conversationID, isPinned: status);
      } catch (e) {
        conversationInfo.value?.isPinned = !status;
        conversationInfo.refresh();
        MukaConfig.config.exceptionCapture.error(e);
      }
    });
  }

  /// 设置消息免打扰
  ///
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  void setConversationRecvMessageOpt(int status, {List<String>? conversationIDList}) {
    if (conversationInfo.value == null && conversationIDList == null) return;
    Utils.exceptionCapture(() async {
      try {
        await OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(conversationIDList: conversationIDList ?? [conversationInfo.value!.conversationID], status: status);
      } catch (e) {
        conversationInfo.value?.recvMsgOpt = status == 2 ? 0 : 2;
        conversationInfo.refresh();
        MukaConfig.config.exceptionCapture.error(e);
      }
    });
  }

  /// 删除聊天记录
  void clearHistoryMessage({Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      if (isGroupChat) {
        assert(gId != null, 'gId 不能为空');
        await OpenIM.iMManager.messageManager.clearGroupHistoryMessage(gid: gId!);
        data.clear();
        onSuccess?.call();
      } else {
        assert(uId != null, 'uId 不能为空');
        await OpenIM.iMManager.messageManager.clearC2CHistoryMessage(uid: uId!);
        data.clear();
        onSuccess?.call();
      }
    });
  }

  /// 退出群聊
  void quitGroup({Function? onSuccess}) {
    if (conversationInfo.value == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.quitGroup(gid: gId!);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value!.conversationID);
      onSuccess?.call();
    });
  }

  /// 删除好友
  void deleteFriend({Function? onSuccess}) {
    if (conversationInfo.value == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.messageManager.clearC2CHistoryMessageFromLocalAndSvr(uid: uId!);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value!.conversationID);
      await OpenIM.iMManager.friendshipManager.deleteFriend(userID: uId!);
      onSuccess?.call();
    });
  }

  /// 双向清除消息
  void doubleCleanMessage(MessageExt extMsg) {
    if (conversationInfo.value == null) return;
    Utils.exceptionCapture(() async {
      AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
        conversationID: conversationInfo.value?.conversationID,
        count: 999999999999999,
        startMsg: extMsg.m,
      );
      if (advancedMessage.messageList.isEmpty) return;
      if (isGroupChat) {
        for (var v in advancedMessage.messageList) {
          OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(message: v);
        }
      } else {
        for (var v in advancedMessage.messageList) {
          OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(message: v);
        }
      }
      data.clear();
      data.insert(0, extMsg);
    });
  }

  /// 解散群聊
  void dismissGroup({Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.dismissGroup(groupID: gId!);
      await OpenIM.iMManager.conversationManager.deleteConversationFromLocalAndSvr(conversationID: conversationInfo.value!.conversationID);
      onSuccess?.call();
    });
  }

  /// 创建名片
  Future<Message> createCardMessage(UserInfo user) async {
    return await OpenIM.iMManager.messageManager.createCardMessage(
      data: {'userID': user.userID, 'nickname': user.nickname, 'faceURL': user.faceURL},
    );
  }

  /// 转发消息
  Future<MessageExt> createForwardMessage(Message msg, String sessionID, int sessionType) async {
    return await (await OpenIM.iMManager.messageManager.createForwardMessage(message: msg)).toExt();
  }

  /// 多选点击事件
  void onMultiSelectTap(MessageExt extMsg) async {
    int index = selectList.indexWhere((v) => extMsg.m.clientMsgID == v.m.clientMsgID);
    if (index != -1) {
      selectList.remove(extMsg);
    } else {
      selectList.add(extMsg);
    }
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

  void onAvatarTap(TapUpDetails details, String userID) {}

  void onAvatarLongPress(String userID) {}

  /// 消息撤回
  void revokeMessage(MessageExt message) {
    Utils.exceptionCapture(() async {
      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      if (conversationInfo.value != null) {
        await OpenIM.iMManager.messageManager.revokeMessage(conversationID: conversationInfo.value!.conversationID, clientMsgID: message.m.clientMsgID ?? '');
      }
    });
    computeTime();
  }

  /// 重新编辑点击事件
  void onReEditTap(MessageExt extMsg) {
    textEditingController.text = extMsg.m.textElem?.content ?? '';
  }

  void onMoreSelectShare() {}

  void onMoreSelectDelete() {}

  /// 重新发送
  void onResend(MessageExt message) async {
    if (!isCanSpeak) return;
    try {
      message.m.status = MessageStatus.sending;
      await updateMessage(message);
      message = await sendMessage(message, text: message.m.atTextElem?.text ?? message.m.textElem?.content);

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

  /// 复制文本
  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// 删除消息
  void deleteMessage(MessageExt extMsg, {Function? onSuccess, Function(Object e)? onError}) {
    Utils.exceptionCapture(() async {
      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      data.removeWhere((v) => v.m.clientMsgID == extMsg.m.clientMsgID);
      await OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(message: extMsg.m);
      onSuccess?.call();
    });
  }

  Widget? contextMenuBuilder(BuildContext context, MessageExt extMsg, {SelectableRegionState? state, Offset? position}) {
    if (position != null) {
      flyoutController.showFlyout(
        position: position,
        barrierColor: Colors.transparent,
        builder: (context) => ChatActions(extMsg: extMsg, controller: this, position: position),
      );
      return null;
    }
    return ChatActions(extMsg: extMsg, controller: this, selectableRegionState: state);
  }

  /// 设置多选
  void setMultiSelect() {
    FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    showSelect.value = !showSelect.value;
  }

  /// 全体禁言
  void setAllMute(bool mute, {Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.changeGroupMute(groupID: gId!, mute: mute);
      onSuccess?.call();
    });
  }

  /// 转让群
  void transferGroupOwner(String userID, {Function? onSuccess}) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.transferGroupOwner(gid: gId!, uid: userID);

      /// 更新群成员信息
      int index = groupMembers.indexWhere((v) => v.userID == OpenIM.iMManager.uid);
      int i = showGroupMembers.indexWhere((v) => v.userID == OpenIM.iMManager.uid);
      if (index != -1) {
        groupMembers[index].roleLevel = GroupRoleLevel.member;
        groupMembers.refresh();
      }
      if (i != -1) {
        showGroupMembers[i].roleLevel = GroupRoleLevel.member;
        groupMembers.refresh();
      }
      onSuccess?.call();
    });
  }

  /// 设置群搜索
  void setGroupSearchType(int type, {Function? onSuccess}) {
    /// 原始数据
    String? ex = groupInfo.value?.ex;
    Utils.exceptionCapture(() async {
      Map<String, dynamic> map;
      try {
        map = jsonDecode(groupInfo.value?.ex ?? '{}');
      } catch (e) {
        map = {};
      }
      map['search_opt'] = type;
      String currentEx = jsonEncode(map);
      groupInfo.value?.ex = currentEx;
      groupInfo.refresh();
      await OpenIM.iMManager.groupManager.setGroupInfo(groupID: gId!, ex: currentEx);

      onSuccess?.call();
    }, error: (e) {
      groupInfo.value?.ex = ex;
      groupInfo.refresh();
      MukaConfig.config.exceptionCapture.error(e);
    });
  }

  /// 显示文件sheet
  void showFileSheet() {
    sheetType.value = SheetType.file;
  }

  /// 退出页面前判断
  void onPopInvokedWithResult(bool status, dynamic v) {
    if (sheetType.value == SheetType.none) {
      Get.back();
      return;
    }
    sheetType.value = SheetType.none;
  }

  void onSelectPhotos(List<PhotoManagerPaths> photos) {
    selectPhotos.assignAll(photos);
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  /// 复制文件到剪切板
  void copyFileToClipboard(MessageExt extMsg) async {
    Utils.exceptionCapture(() async {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        return;
      }
      final item = DataWriterItem();

      item.add(Formats.fileUri.lazy(() => Uri.file(extMsg.ext.file?.path ?? '')));
      clipboard.write([item]);
    });
  }

  /// 转发
  void onForward() async {
    if (conversationInfo.value == null) return;
    if (selectList.isEmpty) {
      // showToast(title: '请先选择要转发的内容', severity: InfoBarSeverity.warning);
      return;
    }

    /// 依据发送时间排序
    selectList.sort((a, b) => a.m.sendTime!.compareTo(b.m.sendTime!));
    // List<SelectDialogData>? list = await home.flyoutController.showFlyout<List<SelectDialogData>?>(
    //   barrierColor: Colors.transparent,
    //   transitionBuilder: (context, animation, placement, child) => FadeTransition(opacity: animation, child: child),
    //   builder: (_) => const SelectFriendDialogView(),
    // );
    // if (list != null) {
    //   for (var v in list) {
    //     Message msg;
    //     String title;
    //     List<String> summaryList = [];
    //     if (selectList.length == 1) {
    //       msg = await OpenIM.iMManager.messageManager.createForwardMessage(message: selectList.first.m);
    //     } else {
    //       for (var v in selectList) {
    //         summaryList.add('${v.m.senderNickname}:${v.m.type.toPlainText()}');
    //         if (summaryList.length > 2) break;
    //       }

    //       if (isGroupChat) {
    //         title = '群聊聊天记录';
    //       } else {
    //         var partner1 = uInfo.getShowName();
    //         String partner2 = conversationInfo.value!.name.nickName;
    //         title = '$partner1和$partner2聊天记录';
    //       }
    //       msg = await OpenIM.iMManager.messageManager.createMergerMessage(messageList: selectList.map((e) => e.m).toList(), title: title, summaryList: summaryList.toList());
    //     }
    //     Message newMsg = await OpenIM.iMManager.messageManager.sendMessage(
    //       userID: v.userID,
    //       groupID: v.groupID,
    //       message: msg,
    //       offlinePushInfo: OfflinePushInfo(title: '你收到了一条新消息', desc: '', iOSBadgeCount: true, iOSPushSound: '+1'),
    //     );
    //     if ((v.userID != null && v.userID!.isNotEmpty && v.userID == userID) || (v.groupID != null && v.groupID!.isNotEmpty && v.groupID == groupID)) {
    //       MessageExt newExtMsg = await newMsg.toExt();
    //       data.insert(0, newExtMsg);
    //     }
    //   }
    //   selectList.clear();
    //   showSelect.value = false;
    //   showToast(title: '转发成功', severity: InfoBarSeverity.success);
    // }
  }
}
