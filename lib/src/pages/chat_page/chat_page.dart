part of '../../../im_kit.dart';

List<String> _keys = ImCore.emojiFaces.keys.toList();

class ChatPage extends StatelessWidget {
  final ChatPageController controller;

  final List<Widget> actions;

  const ChatPage({
    super.key,
    required this.controller,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImLanguage language = ImKitTheme.of(context).language;
    return DropRegion(
      formats: Formats.standardFormats,
      onPerformDrop: controller.onPerformDrop,
      onDropEnter: controller.onDropEnter,
      onDropLeave: controller.onDropLeave,
      onDropOver: controller.onDropOver,
      child: Stack(
        children: [
          Obx(
            () => Container(
              color: controller.isDrop.value ? Colors.grey.withOpacity(0.1) : null,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.focusedChild?.unfocus();
              }
            },
            child: GetBuilder(
              key: ValueKey(controller.isInit ? controller.conversationInfo.value?.conversationID : const Uuid().v4()),
              init: controller,
              tag: controller.isInit ? controller.conversationInfo.value?.conversationID : const Uuid().v4(),
              builder: (controller) => PopScope(
                canPop: false,
                onPopInvokedWithResult: controller.onPopInvokedWithResult,
                child: Scaffold(
                  backgroundColor: chatTheme.backgroundColor,
                  appBar: ImAppBar(
                    label: Obx(
                      () => Text(
                        controller.conversationInfo.value?.title(number: controller.groupMembers.length) ?? '',
                      ),
                    ),
                    actions: [ChatMoreActions(controller: controller)],
                  ),
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Obx(
                                () => ListView.builder(
                                  itemCount: controller.data.length,
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  reverse: controller.isInit,
                                  shrinkWrap: true,
                                  controller: controller.scrollController,
                                  itemBuilder: (context, index) => Obx(
                                    () => ImListItem(
                                      message: controller.data[index],
                                      selected: controller.selectList.indexWhere((v) => v.m.clientMsgID == controller.data[index].m.clientMsgID) != -1,
                                      sendLoadingWidget: const SpinKitFadingCircle(size: 20, color: Colors.grey),
                                      sendErrorWidget: GestureDetector(
                                        onTap: () {
                                          controller.onResend(controller.data[index]);
                                        },
                                        child: const Icon(Icons.error, color: Colors.red, size: 18),
                                      ),
                                      showSelect: controller.showSelect.value,
                                      onTapDownFile: controller.onTapDownFile,
                                      onTapPlayVideo: controller.onTapPlayVideo,
                                      onPictureTap: controller.onPictureTap,
                                      onNotificationUserTap: controller.onNotificationUserTap,
                                      onTapUrl: controller.onUrlTap,
                                      onAtTap: controller.onAtTap,
                                      onTapEmail: controller.onTapEmail,
                                      onTapPhone: controller.onTapPhone,
                                      onCardTap: controller.onCardTap,
                                      onLocationTap: controller.onLocationTap,
                                      onFileTap: controller.onFileTap,
                                      onMergerTap: controller.onMergerTap,
                                      onCopyTip: controller.onCopyTip,
                                      onReEditTap: controller.onReEditTap,
                                      onMessageSelect: controller.onMessageSelect,
                                      onQuoteMessageTap: controller.onQuoteMessageTap,
                                      onVoiceTap: controller.onVoiceTap,
                                      onAvatarTap: controller.onAvatarTap,
                                      onAvatarLongPress: controller.onAvatarLongPress,
                                      onDoubleTapFile: controller.onDoubleTapFile,
                                      onAvatarRightTap: controller.onAvatarRightTap,
                                      highlight: controller.currentIndex.value == index,
                                      contextMenuBuilder: controller.contextMenuBuilder,
                                      sendSuccessWidget: controller.isInit
                                          ? Text(
                                              controller.data[index].m.isRead == true ? '已读' : '未读',
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: EdgeInsets.only(bottom: controller.sheetType.value == SheetType.none ? 0 : Get.mediaQuery.size.height * 0.4 - 30),
                              child: Visibility(
                                visible: controller.showSelect.value,
                                replacement: ChatInputView(controller: controller),
                                child: _buildMoreBottomView(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Visibility(
                          visible: controller.sheetType.value == SheetType.file,
                          child: DraggableScrollableSheetManager(
                            onTap: controller.onSelectPhotos,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(241, 241, 241, 1),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => controller.quoteMessage.value == null
                  ? Container()
                  : ImQuote(
                      padding: EdgeInsets.zero,
                      isMe: controller.quoteMessage.value?.m.sendID == OpenIM.iMManager.uid,
                      message: controller.quoteMessage.value!,
                      showSelect: false,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: controller.onQuoteMessageDelete,
            child: Image.asset('assets/icons/close.png', width: 12, height: 12, package: 'im_kit'),
          ),
        ],
      ),
    );
  }

  /// 绘制多选框
  Widget _buildMoreBottomView() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0d000000),
            offset: Offset(0, -3),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              onPressed: controller.onMoreSelectShare,
              icon: const CachedImage(assetUrl: 'assets/icons/share.png', width: 22, height: 22),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {},
              icon: const CachedImage(assetUrl: 'assets/icons/collect.png', width: 22, height: 22),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: controller.onMoreSelectDelete,
              icon: const CachedImage(assetUrl: 'assets/icons/delete.png', width: 22, height: 22),
            ),
          ),
        ],
      ),
    );
  }
}
