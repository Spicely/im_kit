part of im_kit;

List<String> _keys = _emojiFaces.keys.toList();

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
    int count = (actions.length / 8).ceil();
    return GetBuilder(
      // init: ,
      init: controller,
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
          actions: appBarActions,
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(
                () => EasyRefresh.builder(
                  controller: controller.easyRefreshController,
                  clipBehavior: Clip.none,
                  footer: BuilderFooter(
                      triggerOffset: 40,
                      infiniteOffset: 60,
                      clamping: false,
                      position: IndicatorPosition.above,
                      processedDuration: Duration.zero,
                      builder: (context, state) {
                        return Stack(
                          children: [
                            SizedBox(
                              height: state.offset,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 40,
                                child: SpinKitCircle(
                                  size: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          ],
                        );
                      }),
                  onLoad: controller.noMore.value ? null : controller.onLoad,
                  childBuilder: (context, physics) => Obx(
                    () => ListView.builder(
                      physics: physics,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      controller: controller.scrollController,
                      reverse: true,
                      itemBuilder: (context, index) => ImListItem(
                        message: controller.data[index],
                        // onTap: controller.onTap,
                        // sendLoadingWidget: const SizedBox(width: 15, height: 15, child: RiveAnimation.asset('assets/rive/timer.riv')),
                        sendErrorWidget: const Icon(Icons.error, color: Colors.red),
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
                        sendSuccessWidget: Text(
                          controller.data[index].m.isRead == true ? '已读' : '未读',
                          // style: TextStyle(fontSize: 10, color: gray),
                        ),
                      ),
                      itemCount: controller.data.length,
                    ),
                  ),
                ),
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
                                focusNode: controller.focusNode,
                                maxLines: null,
                                maxLength: null,
                                decoration: InputDecoration(
                                  hintText: chatTheme.textFieldTheme.hintText,
                                ),
                                specialTextSpanBuilder: ExtendSpecialTextSpanBuilder(
                                  allAtMap: [],
                                  // quoteMessage: [],
                                  groupMembersInfo: [],
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
                    offstage: !(controller.fieldType.value == ImChatPageFieldType.emoji),
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
                              indicator: const BubbleTabIndicator(
                                indicatorHeight: 36.0,
                                insets: EdgeInsets.symmetric(horizontal: 28.5),
                                indicatorColor: Colors.white,
                                indicatorRadius: 8,
                                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                              ),
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
                                          assetUrl: 'assets/emoji/${_emojiFaces[_keys[index]]}.webp',
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
                      height: 226,
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
              ],
            )
          ],
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}
