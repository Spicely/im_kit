part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(MessageExt message)? onTapDownFile;

  final void Function(MessageExt message)? onTap;

  /// 失败重发
  final void Function(MessageExt message)? onTapResend;

  /// 通知用户点击事件
  final void Function(UserInfo userInfo)? onNotificationUserTap;

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

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  const ImListItem({
    super.key,
    required this.message,
    this.onTapDownFile,
    this.onTap,
    this.sendLoadingWidget,
    this.sendErrorWidget,
    this.sendSuccessWidget,
    this.onNotificationUserTap,
    this.onTapResend,
    this.onBuildBeforeMsg,
    this.onClickMenu,
    this.textMenuItems,
  });
  @override
  Widget build(BuildContext context) {
    if (message.m.contentType == MessageType.friendAddedNotification) {
      return Container();
    }
    return Directionality(
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: getContentType(),
      ),
    );
  }

  Widget getContentType() {
    switch (message.m.contentType) {
      case MessageType.friendApplicationApprovedNotification:
        return const Center(
          child: Text('你们已成为好友，可以开始聊天了', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
      case MessageType.groupCreatedNotification:
        return Center(
          child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${message.m.senderNickname} ',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (OpenIM.iMManager.uid == message.m.sendID) {
                          OpenIM.iMManager.userManager.getSelfUserInfo().then((v) {
                            onNotificationUserTap?.call(v);
                          });
                        } else {
                          OpenIM.iMManager.friendshipManager.getFriendsInfo(uidList: [message.m.sendID!]).then((v) {
                            onNotificationUserTap?.call(v.first);
                          });
                        }
                      },
                  ),
                  const TextSpan(text: '创建群聊'),
                ],
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        );
      default:
        return Row(
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
            Row(
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
          ],
        );
    }
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
