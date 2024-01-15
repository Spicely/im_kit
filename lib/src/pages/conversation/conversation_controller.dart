part of im_kit;

class ConversationController extends GetxController with OpenIMListener, ImKitListen {
  String get title => unReadMsg.value == 0 ? 'MOYO' : 'MOYO(${unReadMsg.value})';

  RxList<ConversationInfo> data = RxList([]);

  /// 未读消息
  RxInt unReadMsg = 0.obs;

  TapDownDetails? details;

  /// 当前选中的会话信息
  ConversationInfo? currentConversationInfo;

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
  void onConversationChanged(List<ConversationInfo> list) {
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
    currentConversationInfo = info;
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
          OpenIM.iMManager.conversationManager.deleteConversationFromLocalAndSvr(conversationID: info.conversationID);
          data.remove(info);
          Get.back();
        },
      ),
    );
  }

  void onTapDown(TapDownDetails dragDownDetails, ConversationInfo info) {
    details = dragDownDetails;
  }

  void onLongPress() {}

  /// 鼠标按下
  void _onPointerDown(ConversationInfo conversationInfo, PointerDownEvent event) {
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
}
