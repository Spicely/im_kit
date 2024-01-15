part of im_kit;

class SystemNotificationController extends GetxController with OpenIMListener {
  late Rx<ConversationInfo> conversationInfo;

  late RxList<MessageExt> data;

  final ScrollController scrollController = ScrollController();

  SystemNotificationController({
    required ConversationInfo conversationInfo,
    required List<MessageExt> messages,
  }) {
    this.conversationInfo = Rx(conversationInfo);
    data = RxList(messages.reversed.toList());
  }

  @override
  void onInit() {
    OpenIMManager.addListener(this);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  void onClose() {
    OpenIMManager.removeListener(this);
    super.onClose();
  }

  @override
  void onConversationChanged(List<ConversationInfo> list) {
    for (var item in list) {
      if (item.conversationID == conversationInfo.value.conversationID) {
        conversationInfo.value = item;
        break;
      }
    }
  }

  Future<void> getData() async {
    markMessage();
    AdvancedMessage advancedMessage = await OpenIM.iMManager.messageManager.getAdvancedHistoryMessageList(
      conversationID: conversationInfo.value.conversationID,
      count: 20,
    );
    data.value = await advancedMessage.toExt();
  }

  @override
  void onRecvNewMessage(Message msg) {
    if (conversationInfo.value.userID == msg.sendID) {
      msg.toExt().then((extMsg) async {
        data.insert(0, extMsg);
        markMessage();
      });
    }
  }

  void markMessage() {
    OpenIM.iMManager.messageManager.markMessageAsReadByMsgID(conversationID: conversationInfo.value.conversationID, messageIDList: []);
  }
}
