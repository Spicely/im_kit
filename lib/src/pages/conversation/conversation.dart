part of im_kit;

class Conversation extends StatelessWidget {
  final bool isDel;

  final PreferredSizeWidget? appBar;

  final ConversationController controller;

  final Widget? header;

  const Conversation({
    super.key,
    this.isDel = false,
    this.appBar,
    required this.controller,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    return FluentTheme(
      data: FluentThemeData(),
      child: GetBuilder(
        init: controller,
        builder: (c) => Column(
          children: [
            appBar ?? const SizedBox(),
            Expanded(
              child: ListView(
                children: [
                  if (header != null) header!,
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Listener(
                          onPointerDown: (PointerDownEvent event) {
                            controller.onPointerDown(controller.data[index], event);
                          },
                          child: GestureDetector(
                            onTapDown: (TapDownDetails details) {
                              controller.onTapDown(details, c.data[index]);
                            },
                            onLongPress: controller.onLongPress,
                            child: Obx(
                              () => ListTile.selectable(
                                selected: controller.currentConversationID.value == c.data[index].conversationID || c.data[index].isPinned!,
                                onSelectionChange: (_) {},
                                selectionMode: ListTileSelectionMode.none,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                                onPressed: () {
                                  c.toChatPage(c.data[index]);
                                },
                                leading: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CachedImage(
                                      imageUrl: c.data[index].faceURL,
                                      width: 46,
                                      height: 46,
                                      circular: 46,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                    if (c.data[index].recvMsgOpt == 2 && (c.data[index].unreadCount ?? 0) > 0)
                                      Positioned(
                                        right: -6,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ImCore.fixAutoLines(c.data[index].title()),
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500).useSystemChineseFont(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            ImCore.fixAutoLines(c.data[index].latestMsgSendTime?.formatDate() ?? ''),
                                            style: const TextStyle(fontSize: 10, color: Color.fromRGBO(179, 179, 179, 1)).useSystemChineseFont(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text.rich(
                                            Utils.isNotEmpty(c.data[index].draftText)
                                                ? TextSpan(children: [
                                                    TextSpan(text: ImCore.fixAutoLines('[${language.draft}] '), style: const TextStyle(color: Colors.red).useSystemChineseFont()),
                                                    // TextSpan(text: ImCore.fixAutoLines(c.data[index].draftText ?? '' ), style: const TextStyle(color: Colors.grey).useSystemChineseFont()),
                                                    _getAtText(Message(content: c.data[index].draftText ?? '')),
                                                  ])
                                                : c.data[index].latestMsg?.type ?? const TextSpan(),
                                            style: const TextStyle(fontSize: 12, color: Color.fromRGBO(179, 179, 179, 1)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              if (c.data[index].recvMsgOpt == 2) const CachedImage(assetUrl: 'assets/icons/not_disturb.png', width: 14, height: 14, package: 'im_kit'),
                                              if (c.data[index].recvMsgOpt != 2)
                                                Badge.count(
                                                  count: c.data[index].unreadCount ?? 0,
                                                  isLabelVisible: (c.data[index].unreadCount ?? 0) > 0 ? true : false,
                                                  backgroundColor: const Color.fromRGBO(254, 60, 60, 1),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: c.data.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
