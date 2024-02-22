part of im_kit;

List<String> _keys = ImCore.emojiFaces.keys.toList();

class ChatPage extends StatelessWidget {
  final ChatPageController controller;

  final List<Widget> actions;

  final List<Widget> appBarActions;

  const ChatPage({
    super.key,
    required this.controller,
    this.appBarActions = const [],
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImLanguage language = ImKitTheme.of(context).language;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: GetBuilder(
        key: ValueKey(controller.conversationInfo.value.conversationID),
        init: controller,
        tag: controller.conversationInfo.value.conversationID,
        builder: (controller) => Scaffold(
          backgroundColor: chatTheme.backgroundColor,
          appBar: Utils.isDesktop
              ? null
              : AppBar(
                  backgroundColor: chatTheme.appBarTheme.backgroundColor,
                  iconTheme: chatTheme.appBarTheme.iconTheme,
                  leading: Obx(
                    () => Visibility(
                      visible: controller.showSelect.value,
                      replacement: TextButton(
                        onPressed: Get.back,
                        child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      ),
                      child: TextButton(
                        onPressed: () {
                          controller.selectList.clear();
                          controller.showSelect.value = false;
                        },
                        child: Text(language.cancel, style: const TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  title: Column(
                    children: [
                      Obx(
                        () => Text(
                          controller.conversationInfo.value.title(number: controller.groupMembers.length),
                          style: chatTheme.appBarTheme.style,
                        ),
                      ),
                      // controller.isTyping.value ? Text(S.current.typing, style: TextStyle(fontSize: 10.sp, color: gray)) : const SizedBox(),
                    ],
                  ),
                  centerTitle: chatTheme.appBarTheme.centerTitle,
                  actions: appBarActions,
                ),
          body: Obx(
            () => EasyRefresh.builder(
              controller: controller.easyRefreshController,
              clipBehavior: Clip.none,
              // footer: BuilderFooter(
              //   triggerOffset: 40,
              //   infiniteOffset: 60,
              //   clamping: false,
              //   position: IndicatorPosition.above,
              //   processedDuration: Duration.zero,
              //   builder: (context, state) {
              //     return Stack(
              //       children: [
              //         SizedBox(height: state.offset, width: double.infinity),
              //         Positioned(
              //           bottom: 0,
              //           left: 0,
              //           right: 0,
              //           child: Container(
              //             alignment: Alignment.center,
              //             width: double.infinity,
              //             height: 40,
              //             child: SpinKitCircle(size: 24, color: Theme.of(context).primaryColor),
              //           ),
              //         )
              //       ],
              //     );
              //   },
              // ),
              onLoad: controller.noMore.value ? null : controller.onLoad,
              childBuilder: (context, physics) => Obx(
                () => ScrollablePositionedList.builder(
                  itemCount: controller.data.length,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  physics: physics,
                  reverse: true,
                  shrinkWrap: true,
                  itemScrollController: controller.itemScrollController,
                  itemBuilder: (context, index) => Obx(
                    () => ImListItem(
                      message: controller.data[index],
                      selected: controller.selectList.indexWhere((v) => v.m.clientMsgID == controller.data[index].m.clientMsgID) != -1,
                      // onTap: controller.onTap,
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
                      onTapPhone: controller.onTapPhone,
                      onCardTap: controller.onCardTap,
                      onLocationTap: controller.onLocationTap,
                      onFileTap: controller.onFileTap,
                      onForwardMessage: controller.onForwardMessage,
                      onCopyTip: controller.onCopyTip,
                      onDeleteMessage: controller.onDeleteMessage,
                      onMultiSelectTap: controller.onMultiSelectTap,
                      onQuoteMessage: controller.onQuoteMessage,
                      onMessageSelect: controller.onMessageSelect,
                      onRevokeMessage: controller.revokeMessage,
                      onQuoteMessageTap: controller.onQuoteMessageTap,
                      onVoiceTap: controller.onVoiceTap,
                      onAvatarTap: controller.onAvatarTap,
                      onAvatarLongPress: controller.onAvatarLongPress,
                      onDoubleTapFile: controller.onDoubleTapFile,
                      onPointerRightDown: controller.onPointerRightDown,
                      highlight: controller.currentIndex.value == index,
                      contextMenuBuilder: controller.contextMenuBuilder,
                      sendSuccessWidget: Text(
                        controller.data[index].m.isRead == true ? '已读' : '未读',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Utils.isMobile
              ? Obx(
                  () => Visibility(
                    visible: controller.showSelect.value,
                    replacement: _buildBottomInput(context),
                    child: _buildMoreBottomView(),
                  ),
                )
              : null,
        ),
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

  /// 绘制输入框
  Widget _buildBottomInput(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImLanguage language = ImKitTheme.of(context).language;
    int count = (actions.length / 8).ceil();

    double gap = 10;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => Visibility(
            visible: controller.quoteMessage.value != null,
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 58),
                  Expanded(child: _buildQuoteView()),
                  const SizedBox(width: 106),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: chatTheme.textFieldTheme.backgroundColor,
          ),
          padding: EdgeInsets.symmetric(horizontal: gap),
          constraints: BoxConstraints(
            minHeight: chatTheme.textFieldTheme.height,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: controller.isMute.value || controller.isMuteUser.value ? null : controller.onVoiceChanged,
                child: Padding(
                  padding: EdgeInsets.only(right: gap),
                  child: controller.fieldType.value == ImChatPageFieldType.voice ? const CachedImage(assetUrl: 'assets/icons/keyboard.png', package: 'im_kit', width: 28, height: 28) : const CachedImage(assetUrl: 'assets/icons/chat_voice.png', package: 'im_kit', width: 28, height: 28),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: chatTheme.textFieldTheme.textFieldColor,
                        borderRadius: chatTheme.textFieldTheme.textFieldBorderRadius,
                      ),
                      clipBehavior: Clip.hardEdge,
                      constraints: const BoxConstraints(maxHeight: 230),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Obx(
                        () => ExtendedTextField(
                          controller: controller.textEditingController,
                          focusNode: controller.focusNode,
                          maxLines: null,
                          maxLength: null,
                          textAlign: controller.isMute.value || controller.isMuteUser.value ? TextAlign.center : TextAlign.start,
                          readOnly: controller.isMute.value || controller.isMuteUser.value,
                          onTap: () {
                            controller._keyboardShowHeight.value = controller._keyboardHeight.value;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            isCollapsed: true,
                            fillColor: chatTheme.textFieldTheme.textFieldColor,
                            // border:OutlineInputBorder(
                            //   gapPadding: 0,
                            //   borderRadius: BorderRadius.circular(30)
                            // ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                            hintText: controller.isMute.value
                                ? language.groupMutedNotification
                                : controller.isMuteUser.value
                                    ? language.personalMutedNotification
                                    : chatTheme.textFieldTheme.hintText,
                          ),
                          specialTextSpanBuilder: ExtendSpecialTextSpanBuilder(
                            allAtMap: controller.atUserMap,
                            quoteMessage: controller.quoteMessage.value?.m,
                            groupMembersInfo: controller.groupMembers,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: controller.isMute.value || controller.isMuteUser.value ? null : controller.onShowEmoji,
                  child: Padding(
                    padding: EdgeInsets.only(left: gap),
                    child: const CachedImage(assetUrl: 'assets/icons/chat_emoji.png', package: 'im_kit', width: 28, height: 28),
                  ),
                ),
              ),
              Obx(
                () => Offstage(
                  offstage: !controller.hasInput.value,
                  child: GestureDetector(
                    onTap: controller.onSendMessage,
                    child: Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: const CachedImage(assetUrl: 'assets/icons/chat_send.png', package: 'im_kit', width: 28, height: 28),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Offstage(
                  offstage: controller.hasInput.value,
                  child: GestureDetector(
                    onTap: controller.isMute.value || controller.isMuteUser.value ? null : controller.onShowActions,
                    child: Padding(
                      padding: EdgeInsets.only(left: gap),
                      child: const CachedImage(assetUrl: 'assets/icons/chat_action.png', package: 'im_kit', width: 28, height: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Visibility(
            replacement: Obx(() => Container(height: controller._keyboardShowHeight.value, color: chatTheme.textFieldTheme.backgroundColor)),
            visible: controller.fieldType.value != ImChatPageFieldType.none,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Offstage(
                    offstage: !(controller.fieldType.value == ImChatPageFieldType.emoji),
                    child: Container(
                      height: controller._keyboardHeight.value,
                      color: chatTheme.textFieldTheme.backgroundColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 46,
                            width: double.infinity,
                            child: TabBar(
                              isScrollable: true,
                              controller: controller.tabController,
                              indicator: const BubbleTabIndicator(
                                indicatorHeight: 36.0,
                                insets: EdgeInsets.symmetric(horizontal: 28.5),
                                indicatorColor: Colors.white,
                                indicatorRadius: 8,
                                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                              ),
                              tabAlignment: TabAlignment.start,
                              dividerColor: chatTheme.textFieldTheme.backgroundColor,
                              tabs: [
                                const Tab(icon: CachedImage(assetUrl: 'assets/icons/chat_emoji.png', package: 'im_kit', width: 22, height: 22)),
                                ...controller.tabs.map((e) => e.tab).toList(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: controller.tabController,
                              children: [
                                GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 5,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        controller.textEditingController.text += _keys[index];
                                      },
                                      child: Center(
                                        child: CachedImage(
                                          assetUrl: 'assets/emoji/${ImCore.emojiFaces[_keys[index]]}.webp',
                                          width: 27,
                                          height: 27,
                                          package: 'im_kit',
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: _keys.length,
                                ),
                                ...controller.tabs.map((e) => e.view.call(controller)).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Offstage(
                    offstage: !(controller.fieldType.value == ImChatPageFieldType.actions),
                    child: Container(
                      height: controller._keyboardHeight.value,
                      color: chatTheme.textFieldTheme.backgroundColor,
                      child: Swiper(
                        loop: false,
                        itemBuilder: (BuildContext context, int i) {
                          return GridView(
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 5,
                              childAspectRatio: 1.0,
                            ),
                            children: List.generate(actions.length > 8 ? 8 : actions.length, (index) {
                              if (count > 1) {
                                int v = index + 8 * i;
                                if (v >= actions.length) {
                                  return Container();
                                } else {
                                  return actions[v];
                                }
                              } else {
                                return actions[index];
                              }
                            }),
                          );
                        },

                        /// 小数点向上取整
                        itemCount: count,
                        pagination: count <= 1 ? null : const SwiperPagination(),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Offstage(
                    offstage: !(controller.fieldType.value == ImChatPageFieldType.voice),
                    child: SizedBox(
                      height: controller._keyboardHeight.value,
                      child: ImBottomVoice(
                        onVoiceSend: controller.onRecordSuccess,
                        isMute: controller.fieldType.value != ImChatPageFieldType.voice || controller.isMute.value || controller.isMuteUser.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
