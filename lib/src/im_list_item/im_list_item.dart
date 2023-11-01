part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(MessageExt message)? onTapDownFile;

  final void Function(MessageExt message)? onTap;

  /// 双击
  final void Function(MessageExt message)? onDoubleTap;

  /// 失败重发
  final void Function(MessageExt message)? onTapResend;

  /// 通知用户点击事件
  final UserNotificationCallback? onNotificationUserTap;

  /// 消息获取之前处理
  final MessageExt Function(MessageExt message)? onBuildBeforeMsg;

  /// 名片信息点击
  final void Function(MessageExt message)? onCardTap;

  /// 位置信息点击
  final void Function(MessageExt message)? onLocationTap;

  /// 文件信息点击
  final void Function(MessageExt message)? onFileTap;

  /// 群是否被解散
  final bool isGroupDissolution;

  final bool selected;

  /// 发送消息等待Widget
  final Widget? sendLoadingWidget;

  /// 选择消息事件
  final void Function(MessageExt, bool)? onMessageSelect;

  /// 发送消息失败Widget
  final Widget? sendErrorWidget;

  /// 发送消息成功Widget
  final Widget? sendSuccessWidget;

  final void Function(MenuItemProvider, MessageExt)? onClickMenu;

  final List<MenuItemProvider>? textMenuItems;

  final ContextMenuController contextMenuController;

  /// 网址点击事件
  final void Function(String)? onTapUrl;

  /// 邮箱点击事件
  final void Function(String)? onTapEmail;

  /// 电话点击事件
  final void Function(String)? onTapPhone;

  /// 点击播放视频
  final void Function(MessageExt message)? onTapPlayVideo;

  /// 图片点击事件
  final void Function(MessageExt message)? onPictureTap;

  /// at点击事件
  final void Function(UserInfo userInfo)? onAtTap;

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  /// 是否显示选择按钮
  final bool showSelect;

  /// 不允许通过群获取成员资料
  final bool lookMemberInfo;

  /// 消息撤回点击事件
  final Function(MessageExt extMsg)? onRevokeMessage;

  /// 文件保存之后
  final Function(bool status)? onAfterSave;

  /// tag点击事件
  final Function(UserInfo user)? onTagUserTap;

  /// 复制消息提示事件
  final Function(String text)? onCopyTip;

  /// 删除消息
  final Function(MessageExt extMsg)? onDeleteMessage;

  /// 转发消息
  final Function(MessageExt extMsg)? onForwardMessage;

  /// 消息引用\回复
  final Function(MessageExt extMsg)? onQuoteMessage;

  // /// 艾特点击事件
  // final Function(AtUserInfo userInfo)? onAtTap;

  /// 重新发送事件
  final Function(MessageExt extMsg)? onResend;

  /// 多选事件
  final Function(MessageExt extMsg)? onMultiSelectTap;

  const ImListItem({
    super.key,
    required this.message,
    required this.selected,
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
    this.onDoubleTap,
    this.onTapUrl,
    this.onTapEmail,
    this.onTapPhone,
    this.onTapPlayVideo,
    this.onPictureTap,
    this.onAtTap,
    this.onCardTap,
    this.onLocationTap,
    this.onFileTap,
    this.showSelect = false,
    this.isGroupDissolution = false,
    this.lookMemberInfo = false,
    this.onRevokeMessage,
    this.onAfterSave,
    this.onTagUserTap,
    this.onCopyTip,
    this.onDeleteMessage,
    this.onMultiSelectTap,
    this.onForwardMessage,
    this.onQuoteMessage,
    this.onResend,
    this.onMessageSelect,
    required this.contextMenuController,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSelect)
                Checkbox(
                  value: selected,
                  shape: const CircleBorder(),
                  side: BorderSide(
                    width: 1.2,
                    color: message.m.status != MessageStatus.succeeded || message.ext.isVoice || message.ext.isRedEnvelope ? const Color.fromRGBO(175, 175, 175, 0.2) : const Color.fromRGBO(175, 175, 175, 1),
                  ),
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).primaryColor;
                    } else {
                      return Colors.transparent;
                    }
                  }),
                  onChanged: message.m.status != MessageStatus.succeeded || message.ext.isVoice || message.ext.isRedEnvelope
                      ? null
                      : (value) {
                          onMessageSelect?.call(message, !selected);
                        },
                ),
              Expanded(child: getContentType(context)),
            ],
          )),
    );
  }

  Widget getContentType(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImAvatarTheme avatarTheme = ImKitTheme.of(context).chatTheme.avatarTheme;
    switch (message.m.contentType) {
      case MessageType.custom:
        switch (message.ext.data['contentType']) {
          case 81:
            return ImRedEnv(isMe: isMe, message: message, contextMenuController: contextMenuController);
          case 82:
            return Center(
              child: Text.rich(
                _getRedEnvelope(message, message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );

          default:
            return const Center(
              child: Text('暂不支持的消息', style: TextStyle(fontSize: 12, color: Colors.grey)),
            );
        }
      case MessageType.friendApplicationApprovedNotification:
        return const Center(
          child: Text('你们已成为好友，可以开始聊天了', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );

      case MessageType.memberKickedNotification:
        return Center(
          child: Text.rich(
            _getMemberKickedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case MessageType.revoke:
        return Center(
          child: Text.rich(
            _getRevoke(message, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );

      case MessageType.groupInfoSetNotification:
      case MessageType.groupCreatedNotification:
      case MessageType.groupMemberCancelMutedNotification:
      case MessageType.groupMemberMutedNotification:
      case MessageType.memberEnterNotification:
        return Center(
          child: Text.rich(
            _getNotification(message.ext.data, message.m.contentType!, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case MessageType.memberInvitedNotification:
        return Center(
          child: Text.rich(
            _getMemberInvitedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );

      default:
        return GestureDetector(
          onTap: onSelectTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedImage(
                imageUrl: message.m.senderFaceUrl,
                width: avatarTheme.width,
                height: avatarTheme.height,
                circular: avatarTheme.circular,
                fit: avatarTheme.fit,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.m.isGroupChat && !isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(message.m.senderNickname ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          Wrap(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print(111);
                                  onSelectTap();
                                  onTap?.call(message);
                                },
                                onDoubleTap: () {
                                  onDoubleTap?.call(message);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: ImCore.noBgMsgType.contains(message.m.contentType)
                                            ? null
                                            : isMe
                                                ? chatTheme.messageTheme.meBackgroundColor
                                                : chatTheme.messageTheme.backgroundColor,
                                        borderRadius: chatTheme.messageTheme.borderRadius,
                                      ),
                                      padding: ImCore.noPadMsgType.contains(message.m.contentType) ? null : chatTheme.messageTheme.padding,
                                      child: getTypeWidget(),
                                    ),
                                    if (message.m.contentType == MessageType.quote)
                                      Container(
                                        margin: const EdgeInsets.only(top: 5),
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Wrap(
                                            children: [
                                              ImQuoteItem(isMe: isMe, message: message, contextMenuController: contextMenuController),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // SizedBox(child: getStatusWidget()),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  void onSelectTap() {
    if (showSelect) {
      if (message.m.status != MessageStatus.succeeded) return;
      if (message.ext.isVoice) return;
      if (message.ext.isRedEnvelope) return;
      onMessageSelect?.call(message, !selected);
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
      case MessageType.quote:
        return ImAtText(
          message: onBuildBeforeMsg != null ? onBuildBeforeMsg!.call(message) : message,
          isMe: isMe,
          onClickMenu: onClickMenu,
          textMenuItems: textMenuItems,
          onTapEmail: onTapEmail,
          onTapUrl: onTapUrl,
          onTapPhone: onTapPhone,
          onAtTap: onAtTap,
          onDeleteTap: onDeleteMessage,
          onForwardTap: onForwardMessage,
          onMultiSelectTap: onMultiSelectTap,
          onQuoteTap: onQuoteMessage,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.picture:
        return ImImage(
          message: message,
          isMe: isMe,
          onTap: onPictureTap,
          contextMenuController: contextMenuController,
          onDeleteTap: onDeleteMessage,
          onForwardTap: onForwardMessage,
          onMultiSelectTap: onMultiSelectTap,
          onQuoteTap: onQuoteMessage,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.file:
        return ImFile(
          message: message,
          isMe: isMe,
          onTap: onFileTap,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.voice:
        return ImVoice(
          message: message,
          isMe: isMe,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.video:
        return ImVideo(
          message: message,
          isMe: isMe,
          onTapDownFile: onTapDownFile,
          onTapPlayVideo: onTapPlayVideo,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.card:
        return ImCard(
          message: message,
          isMe: isMe,
          onTap: onCardTap,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.location:
        return ImLocation(
          message: message,
          isMe: isMe,
          onTap: onLocationTap,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case MessageType.merger:
        return ImMerge(
          message: message,
          isMe: isMe,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      case 300:
        return ImCustomFace(
          message: message,
          isMe: isMe,
          contextMenuController: contextMenuController,
          onRevokeTap: onRevokeMessage,
        );
      default:
        return const Text('暂不支持的消息');
    }
  }
}
