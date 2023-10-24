part of im_kit;

class ConversationController extends GetxController with OpenIMListener {
  String get title => unReadMsg.value == 0 ? 'MOYO' : 'MOYO(${unReadMsg.value})';

  RxList<ConversationInfo> data = RxList([]);

  /// 未读消息
  RxInt unReadMsg = 0.obs;

  /// 密钥列表
  Map<String, String> keyMap = {};

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
    String secretKey;
    if (msg.sessionType == 1) {
      secretKey = keyMap[msg.sendID] ?? '';
    } else {
      secretKey = keyMap[msg.groupID] ?? '';
    }
    MessageExt extMsg = msg.toExt(secretKey);
    ImCore.downloadFile(extMsg);
  }

  Future<void> getData() async {
    var keys = await OpenIM.iMManager.conversationManager.getAllLocalKey();
    for (var value in keys) {
      keyMap[value['sessionID']] = value['sessionKey'];
    }
    data.value = await OpenIM.iMManager.conversationManager.getAllConversationList();
    OpenIM.iMManager.conversationManager.simpleSort(data);
  }

  String getKey(ConversationInfo info) {
    if (info.conversationType == 1) {
      return keyMap[info.userID] ?? '';
    } else {
      return keyMap[info.groupID] ?? '';
    }
  }

  void onNotificationUserTap(UserInfo userInfo) {
    print(userInfo);
  }

  /// 跳转到聊天页面
  Future<void> toChatPage(ConversationInfo info) async {
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: info.conversationID,
      count: 40,
    );
    String secretKey = getKey(info);
    Get.to(
      () => ChatPage(
        conversationInfo: info,
        messages: advancedMessage.toExt(secretKey),
        secretKey: secretKey,
        onNotificationUserTap: onNotificationUserTap,
      ),
    );
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
}
