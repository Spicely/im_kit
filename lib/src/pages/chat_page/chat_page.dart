part of im_kit;

class ChatPage extends StatelessWidget {
  final List<MessageExt> messages;

  final ConversationInfo conversationInfo;

  final String secretKey;

  const ChatPage({
    super.key,
    required this.secretKey,
    required this.messages,
    required this.conversationInfo,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return GetBuilder(
      init: ChatPageController(secretKey: secretKey, messages: messages, conversationInfo: conversationInfo),
      builder: (controller) => Scaffold(
        backgroundColor: chatTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: chatTheme.appBarTheme.backgroundColor,
          iconTheme: chatTheme.appBarTheme.iconTheme,
          title: Column(
            children: [
              Obx(
                () => Text(
                  controller.conversationInfo.value.title(number: controller.groupMemberInfo.length),
                  style: chatTheme.appBarTheme.style,
                ),
              ),
              // controller.isTyping.value ? Text(S.current.typing, style: TextStyle(fontSize: 10.sp, color: gray)) : const SizedBox(),
            ],
          ),
          centerTitle: chatTheme.appBarTheme.centerTitle,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: chatTheme.textFieldTheme.backgroundColor,
                  ),
                  constraints: BoxConstraints(
                    minHeight: chatTheme.textFieldTheme.height,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const CachedImage(assetUrl: 'assets/icons/chat_voice.png', package: 'im_kit', width: 24, height: 24),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              // height: chatTheme.textFieldTheme.textFieldHeight,
                              decoration: BoxDecoration(
                                color: chatTheme.textFieldTheme.textFieldColor,
                                borderRadius: chatTheme.textFieldTheme.textFieldBorderRadius,
                              ),
                              constraints: const BoxConstraints(maxHeight: 230),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: ExtendedTextField(
                                controller: controller.textEditingController,
                                maxLines: null,
                                maxLength: null,
                                decoration: InputDecoration(
                                  hintText: chatTheme.textFieldTheme.hintText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.onShowEmoji,
                        icon: const CachedImage(assetUrl: 'assets/icons/chat_emoji.png', package: 'im_kit', width: 24, height: 24),
                      ),
                      Obx(
                        () => Offstage(
                          offstage: !controller.hasInput.value,
                          child: IconButton(
                            onPressed: controller.onSendMessage,
                            icon: const CachedImage(assetUrl: 'assets/icons/chat_send.png', package: 'im_kit', width: 24, height: 24),
                          ),
                        ),
                      ),
                      Obx(
                        () => Offstage(
                          offstage: controller.hasInput.value,
                          child: IconButton(
                            onPressed: controller.onShowActions,
                            icon: const CachedImage(assetUrl: 'assets/icons/chat_action.png', package: 'im_kit', width: 24, height: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Offstage(
                    offstage: !(controller.fieldType.value == FieldType.emoji),
                    child: Container(
                      height: 306,
                      color: chatTheme.textFieldTheme.backgroundColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 46,
                            width: double.infinity,
                            child: TabBar(
                              isScrollable: true,
                              controller: controller.tabController,
                              indicatorWeight: 10,
                              tabs: const [
                                Tab(icon: CachedImage(assetUrl: 'assets/icons/chat_emoji.png', package: 'im_kit', width: 22, height: 22)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Offstage(
                    offstage: !(controller.fieldType.value == FieldType.actions),
                    child: Container(
                      height: 226,
                      color: chatTheme.textFieldTheme.backgroundColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
