part of im_kit;

class ConversationController extends GetxController with OpenIMListener, ImKitListen {
  String get title => unReadMsg.value == 0 ? 'MOYO' : 'MOYO(${unReadMsg.value})';

  RxList<ConversationInfo> data = RxList([]);

  final Rx<dynamic> currentChatPageController = Rx<dynamic>(null);

  Rx<UserInfo> userInfo = Rx(OpenIM.iMManager.uInfo!);

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
    OpenIM.iMManager.conversationManager.simpleSort(data);
  }

  /// 跳转到聊天页面
  Future<void> toChatPage(ConversationInfo info) async {
    currentConversationID.value = info.conversationID;
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: info.conversationID,
      count: 40,
    );

    List<MessageExt> messages = await advancedMessage.toExt();
    Get.to(
      () => ChatPage(
        controller: ChatPageController(messages: messages, conversation: info),
      ),
    );
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
          Utils.exceptionCapture(() async {
            OpenIM.iMManager.conversationManager.deleteConversationFromLocalAndSvr(conversationID: info.conversationID);
            data.remove(info);
            Get.back();
          });
        },
      ),
    );
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
  void pinConversation(ConversationInfo conversation, bool status) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.pinConversation(
        conversationID: conversation.conversationID,
        isPinned: status,
      );
    });
  }

  /// copy群号
  void copyGroupID(ConversationInfo conversation) {
    Utils.exceptionCapture(() async {
      await Clipboard.setData(ClipboardData(text: conversation.groupID ?? ''));
    });
  }

  /// copyID
  void copyID(ConversationInfo conversation) {
    Utils.exceptionCapture(() async {
      await Clipboard.setData(ClipboardData(text: conversation.userID ?? ''));
    });
  }

  /// 删除会话
  void removeConversation(ConversationInfo conversation) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversation.conversationID);
      data.removeWhere((v) => v.conversationID == conversation.conversationID);
    });
  }

  /// 标记已读
  void markConversationRead(ConversationInfo conversation) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.messageManager.markMessageAsReadByMsgID(conversationID: conversation.conversationID, messageIDList: []);
    });
  }

  /// 免打扰
  void setConversationRecvMessageOpt(ConversationInfo conversation, int status) {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(conversationIDList: [conversation.conversationID], status: status);
    });
  }
}
