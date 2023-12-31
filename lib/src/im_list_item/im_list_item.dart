part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(MessageExt message)? onTapDownFile;

  final void Function(MessageExt message)? onTap;

  /// 失败重发
  final void Function(MessageExt message)? onTapResend;

  /// 消息获取之前处理
  final MessageExt Function(MessageExt message)? onBuildBeforeMsg;

  /// 发送消息等待Widget
  final Widget? sendLoadingWidget;

  /// 发送消息失败Widget
  final Widget? sendErrorWidget;

  /// 发送消息成功Widget
  final Widget? sendSuccessWidget;

  final void Function(MenuItemProvider, MessageExt)? onClickMenu;

  final List<MenuItemProvider>? textMenuItems;

  const ImListItem({
    super.key,
    required this.message,
    this.onTapDownFile,
    this.onTap,
    this.sendLoadingWidget,
    this.sendErrorWidget,
    this.sendSuccessWidget,
    this.onTapResend,
    this.onBuildBeforeMsg,
    this.onClickMenu,
    this.textMenuItems,
  });

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  @override
  Widget build(BuildContext context) {
    if (message.m.contentType == MessageType.friendAddedNotification) {
      return Container();
    }
    return Directionality(
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImage(
              imageUrl: message.m.senderFaceUrl,
              width: ImCore.theme.avatarTheme.width,
              height: ImCore.theme.avatarTheme.height,
              circular: ImCore.theme.avatarTheme.circular,
              fit: ImCore.theme.avatarTheme.fit,
            ),
            const SizedBox(width: 10),
            // Container(
            //   color: Colors.white,
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //   child:
            // ),
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      onTap?.call(message);
                    },
                    child: getTypeWidget(),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(child: getStatusWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? getStatusWidget() {
    if (message.m.status == MessageStatus.sending) return sendLoadingWidget;
    if (message.m.status == MessageStatus.failed) {
      return GestureDetector(
        child: sendErrorWidget,
        onTap: () {
          onTapResend?.call(message);
        },
      );
    }
    if (message.m.status == MessageStatus.succeeded && OpenIM.iMManager.uid == message.m.sendID) return sendSuccessWidget;
    return null;
  }

  Widget getTypeWidget() {
    switch (message.m.contentType) {
      case MessageType.text:
      case MessageType.at_text:
        return ImAtText(message: onBuildBeforeMsg != null ? onBuildBeforeMsg!.call(message) : message, isMe: isMe, onClickMenu: onClickMenu, textMenuItems: textMenuItems);
      case MessageType.picture:
        return ImImage(message: message, isMe: isMe);
      case MessageType.file:
        return ImFile(message: message, isMe: isMe, onTapDownFile: onTapDownFile);
      case MessageType.voice:
        return ImVoice(message: message, isMe: isMe);
      case MessageType.video:
        return ImVideo(message: message, isMe: isMe);
      default:
        return const Text('暂不支持的消息');
    }
  }
}
