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
    return GetBuilder(
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
                          controller._onPointerDown(controller.data[index], event);
                        },
                        child: Row(
                          children: [
                            if (isDel)
                              GestureDetector(
                                onTap: () {
                                  c.deleteConversation(c.data[index]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(left: 12),
                                  height: 69,
                                  color: c.data[index].isPinned == true ? const Color.fromRGBO(247, 247, 247, 1) : Colors.white,
                                  child: const Center(
                                    child: CachedImage(
                                      assetUrl: 'assets/icons/c_delete.png',
                                      width: 16,
                                      height: 16,
                                      package: 'im_kit',
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  controller.onTapDown(details, c.data[index]);
                                },
                                child: ListItem(
                                  height: 70,
                                  onLongPress: controller.onLongPress,
                                  color: c.data[index].isPinned == true ? const Color.fromRGBO(247, 247, 247, 1) : Colors.white,
                                  leading: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CachedImage(
                                        imageUrl: c.data[index].faceURL,
                                        width: 46,
                                        height: 46,
                                        circular: 46,
                                        fit: BoxFit.cover,
                                      ),
                                      if (c.data[index].recvMsgOpt == 2 && c.data[index].unreadCount > 0)
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
                                  fieldType: FieldType.title,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.data[index].title(),
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: Text(
                                              c.data[index].latestMsgSendTime?.formatDate() ?? '',
                                              style: const TextStyle(fontSize: 10, color: Color.fromRGBO(179, 179, 179, 1)),
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
                                                      TextSpan(text: '[${language.draft}]', style: const TextStyle(color: Colors.red)),
                                                      TextSpan(text: c.data[index].draftText, style: const TextStyle(color: Colors.grey)),
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
                                                    count: c.data[index].unreadCount,
                                                    isLabelVisible: c.data[index].unreadCount > 0 ? true : false,
                                                    backgroundColor: const Color.fromRGBO(254, 60, 60, 1),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    c.toChatPage(c.data[index]);
                                  },
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
