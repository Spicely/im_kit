part of im_kit;

class ConversationController extends GetxController with OpenIMListener {
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
    super.onInit();
    ever(data, (v) {
      // 统计未读数
      int count = 0;
      for (var info in v) {
        if (info.recvMsgOpt == 0) {
          count += info.unreadCount ?? 0;
        }
      }
      unReadMsg.value = count;
    });
  }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
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

  @override
  void onRecvNewMessage(Message msg) {
    // msg.toExt(secretKey).then((extMsg) {
    //   ImCore.downloadFile(extMsg, secretKey);
    // });
  }

  Future<void> getData() async {
    data.value = await OpenIM.iMManager.conversationManager.getAllConversationList();
    OpenIM.iMManager.conversationManager.simpleSort(data);
  }

  /// 跳转到聊天页面
  Future<void> toChatPage(ConversationInfo info) async {
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: info.conversationID,
      count: 40,
    );
    List<GroupMembersInfo> groupMembers = [];
    GroupInfo? groupInfo;
    if (info.isGroupChat) {
      groupMembers = await OpenIM.iMManager.groupManager.getGroupMemberList(groupId: info.groupID!);
      groupInfo = (await OpenIM.iMManager.groupManager.getGroupsInfo(gidList: [info.groupID!])).first;
    }
    List<MessageExt> messages = await advancedMessage.toExt('');
    Get.to(
      () => ChatPage(
        controller: ChatPageController(
          secretKey: '',
          messages: messages,
          conversationInfo: info,
          groupMembers: groupMembers,
          groupInfo: groupInfo,
        ),
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
    currentConversationInfo = info;
  }

  void onLongPress() {}
}
