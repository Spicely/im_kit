part of im_kit;

class ChatPage extends StatelessWidget {
  final AdvancedMessage advancedMessage;

  final ConversationInfo conversationInfo;

  final String secretKey;

  const ChatPage({
    super.key,
    required this.secretKey,
    required this.advancedMessage,
    required this.conversationInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ChatPageController(secretKey: secretKey, advancedMessage: advancedMessage, conversationInfo: conversationInfo),
      builder: (controller) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Column(
            children: [
              Obx(() => Text(controller.conversationInfo.value.title(number: controller.groupMemberInfo.length))),
              // controller.isTyping.value ? Text(S.current.typing, style: TextStyle(fontSize: 10.sp, color: gray)) : const SizedBox(),
            ],
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          controller: controller.scrollController,
          reverse: true,
          itemBuilder: (context, index) => Obx(
            () => ImListItem(
              message: controller.data[index],
              // onTap: controller.onTap,
              // sendLoadingWidget: const SizedBox(width: 15, height: 15, child: RiveAnimation.asset('assets/rive/timer.riv')),
              sendErrorWidget: const Icon(Icons.error, color: Colors.red),
              onTapDownFile: controller.onTapDownFile,
              onTapPlayVideo: controller.onTapPlayVideo,
              onTapPicture: controller.onTapPicture,
              sendSuccessWidget: Text(
                controller.data[index].m.isRead == true ? '已读' : '未读',
                // style: TextStyle(fontSize: 10, color: gray),
              ),
            ),
          ),
          itemCount: controller.data.length,
        ),
      ),
    );
  }
}
