part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(BuildContext context, MessageExt message)? onTapDownFile;

  final void Function(MessageExt message)? onTap;

  /// 高亮
  final bool highlight;

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

  /// 网址点击事件
  final void Function(String)? onTapUrl;

  /// 邮箱点击事件
  final void Function(String)? onTapEmail;

  /// 电话点击事件
  final void Function(String)? onTapPhone;

  /// 点击播放视频
  final void Function(BuildContext context, MessageExt message)? onTapPlayVideo;

  /// 图片点击事件
  final void Function(MessageExt message)? onPictureTap;

  /// at点击事件
  final void Function(TapUpDetails details, FullUserInfo userInfo)? onAtTap;

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

  /// 重新发送事件
  final Function(MessageExt extMsg)? onResend;

  /// 多选事件
  final Function(MessageExt extMsg)? onMultiSelectTap;

  /// 引用消息点击
  final void Function(MessageExt message)? onQuoteMessageTap;

  /// 语音点击事件
  final void Function(MessageExt message)? onVoiceTap;

  /// 头像点击事件
  final void Function(UserInfo userInfo)? onAvatarTap;

  /// 头像长按事件
  final void Function(UserInfo userInfo)? onAvatarLongPress;

  /// 双击点击消息体
  final void Function(MessageExt message)? onDoubleTapFile;

  /// 鼠标右键点击事件
  final void Function(PointerDownEvent event, MessageExt extMsg)? onPointerRightDown;

  final Widget Function(BuildContext, MessageExt, EditableTextState)? contextMenuBuilder;

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
    this.onQuoteMessageTap,
    this.highlight = false,
    this.onVoiceTap,
    this.onAvatarTap,
    this.onAvatarLongPress,
    this.onDoubleTapFile,
    this.onPointerRightDown,
    this.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight ? Colors.blue.withOpacity(0.1) : null,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          if (message.ext.showTime) ImTime(message: message),
          Directionality(
            textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getContentType(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImAvatarTheme avatarTheme = ImKitTheme.of(context).chatTheme.avatarTheme;
    switch (message.m.contentType) {
      case MessageType.custom:
        switch (message.ext.data['contentType']) {
          case 27:
            return const Center(
              child: Text.rich(
                TextSpan(text: '双方聊天记录已清空'),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          case 77:
            return const Center(
              child: Text.rich(
                TextSpan(text: '群主清除了聊天记录'),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          case 81:
            return ImRedEnv(isMe: isMe, message: message);
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

      case MessageType.groupMutedNotification:
        return const Center(
          child: Text('群组开启禁言', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
      case MessageType.dismissGroupNotification:
        return const Center(
          child: Text('群组已被解散', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
      case MessageType.groupCancelMutedNotification:
        return const Center(
          child: Text('群组取消禁言', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
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
      case MessageType.burnAfterReadingNotification:
        return Center(
          child: Text(
            message.ext.data?['isPrivate'] == true ? '阅后即焚已开启' : '阅后即焚已关闭',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case MessageType.revokeMessageNotification:
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
      case MessageType.memberQuitNotification:
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
          onTap: _onSelectTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _onAvatarTap,
                onLongPress: _onAvatarLongPress,
                child: CachedImage(
                  imageUrl: message.m.senderFaceUrl,
                  width: avatarTheme.width,
                  height: avatarTheme.height,
                  circular: avatarTheme.circular,
                  fit: avatarTheme.fit,
                ),
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
                          GestureDetector(
                            onTap: _onTap,
                            onDoubleTap: () {
                              onDoubleTap?.call(message);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Listener(
                                  onPointerDown: (PointerDownEvent event) {
                                    if (event.buttons == 2) {
                                      onPointerRightDown?.call(event, message);
                                    }
                                  },
                                  child: Container(
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
                                ),
                                // Stack(
                                //   children: [
                                //     Container(
                                //       decoration: BoxDecoration(
                                //         color: ImCore.noBgMsgType.contains(message.m.contentType)
                                //             ? null
                                //             : isMe
                                //             ? chatTheme.messageTheme.meBackgroundColor
                                //             : chatTheme.messageTheme.backgroundColor,
                                //         borderRadius: chatTheme.messageTheme.borderRadius,
                                //       ),
                                //       padding: ImCore.noPadMsgType.contains(message.m.contentType) ? null : chatTheme.messageTheme.padding,
                                //       child:getTypeWidget(),
                                //     ),
                                //     // Positioned(
                                //     //   bottom: 4,
                                //     //   right: 6,
                                //     //   child: Directionality(
                                //     //     textDirection: TextDirection.ltr,
                                //     //     child: Row(
                                //     //       children: [
                                //     //         Text(message.ext.time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                //     //         if (isMe) const SizedBox(width: 1),
                                //     //         if (isMe && message.m.isRead!) const Icon(Icons.done_all, size: 12, color: Colors.blue),
                                //     //       ],
                                //     //     ),
                                //     //   ),
                                //     // ),
                                //   ],
                                // ),
                                if (message.m.contentType == MessageType.quote)
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: ImQuoteItem(
                                      isMe: isMe,
                                      message: message,
                                      onQuoteMessageTap: onQuoteMessageTap,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: avatarTheme.width,
                height: avatarTheme.height,
              )
            ],
          ),
        );
    }
  }

  void _onSelectTap() {
    if (showSelect) {
      if (message.m.status != MessageStatus.succeeded) return;
      if (message.ext.isVoice) return;
      if (message.ext.isRedEnvelope) return;
      onMessageSelect?.call(message, !selected);
    }
  }

  Widget? getStatusWidget() {
    if (message.m.status == MessageStatus.succeeded && message.ext.isPrivateChat && message.m.isRead!) {
      return SizedBox(
        child: Text(
          '${message.ext.seconds}s',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      );
    }
    if (message.m.status == MessageStatus.sending) return sendLoadingWidget;
    if (message.m.status == MessageStatus.failed) {
      return GestureDetector(
        child: sendErrorWidget,
        onTap: () {
          onTapResend?.call(message);
        },
      );
    }
    if (message.m.isSingleChat && message.m.status == MessageStatus.succeeded && OpenIM.iMManager.uid == message.m.sendID) return sendSuccessWidget;
    return null;
  }

  Widget getTypeWidget() {
    switch (message.m.contentType) {
      case MessageType.text:
      case MessageType.atText:
      case MessageType.quote:
        return Padding(
          padding: const EdgeInsets.only(left: 5),
          child: ImAtText(
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
            onRevokeTap: onRevokeMessage,
            contextMenuBuilder: contextMenuBuilder,
          ),
        );
      case MessageType.picture:
        return Stack(
          children: [
            ImImage(
              message: message,
              isMe: isMe,
              onTap: onPictureTap,
              onDeleteTap: onDeleteMessage,
              onForwardTap: onForwardMessage,
              onMultiSelectTap: onMultiSelectTap,
              onQuoteTap: onQuoteMessage,
              onRevokeTap: onRevokeMessage,
              contextMenuBuilder: contextMenuBuilder,
            ),
            Positioned(
              bottom: 4,
              right: 6,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(message.ext.time, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      if (isMe) const SizedBox(width: 1),
                      if (isMe && message.m.isRead!) const Icon(Icons.done_all, size: 12, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case MessageType.file:
        return ImFile(
          message: message,
          isMe: isMe,
          onTap: onFileTap,
          onRevokeTap: onRevokeMessage,
          onDoubleTap: onDoubleTapFile,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.voice:
        return ImVoice(
          message: message,
          isMe: isMe,
          onRevokeTap: onRevokeMessage,
          onTap: onVoiceTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.video:
        return Stack(
          children: [
            ImVideo(
              message: message,
              isMe: isMe,
              onTapDownFile: onTapDownFile,
              onTapPlayVideo: onTapPlayVideo,
              onRevokeTap: onRevokeMessage,
              contextMenuBuilder: contextMenuBuilder,
            ),
            Positioned(
              bottom: 4,
              right: 6,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(message.ext.time, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      if (isMe) const SizedBox(width: 1),
                      if (isMe && message.m.isRead!) const Icon(Icons.done_all, size: 12, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      case MessageType.card:
        return ImCard(
          message: message,
          isMe: isMe,
          onTap: onCardTap,
          onRevokeTap: onRevokeMessage,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.location:
        return Stack(
          children: [
            ImLocation(
              message: message,
              isMe: isMe,
              onTap: onLocationTap,
              onRevokeTap: onRevokeMessage,
              contextMenuBuilder: contextMenuBuilder,
            ),
            Positioned(
              bottom: 4,
              right: 6,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(message.ext.time, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      if (isMe) const SizedBox(width: 1),
                      if (isMe && message.m.isRead!) const Icon(Icons.done_all, size: 12, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      case MessageType.merger:
        return ImMerge(
          message: message,
          isMe: isMe,
          onRevokeTap: onRevokeMessage,
          contextMenuBuilder: contextMenuBuilder,
        );
      case 300:
        return ImCustomFace(
          message: message,
          isMe: isMe,
          onRevokeTap: onRevokeMessage,
        );
      default:
        return const Text('暂不支持的消息');
    }
  }

  void _onTap() {
    _onSelectTap();
    onTap?.call(message);
    switch (message.m.contentType) {
      case MessageType.voice:
        onVoiceTap?.call(message);
        break;
    }
  }

  /// 头像点击
  void _onAvatarTap() {
    if (message.m.sendID == OpenIM.iMManager.uid) {
      onAvatarTap?.call(OpenIM.iMManager.uInfo!);
    } else {
      onAvatarTap?.call(UserInfo(
        userID: message.m.sendID,
        nickname: message.m.senderNickname,
        faceURL: message.m.senderFaceUrl,
      ));
    }
  }

  /// 头像长按
  void _onAvatarLongPress() {
    if (message.m.sendID == OpenIM.iMManager.uid) {
      onAvatarLongPress?.call(OpenIM.iMManager.uInfo!);
    } else {
      onAvatarLongPress?.call(UserInfo(
        userID: message.m.sendID,
        nickname: message.m.senderNickname,
        faceURL: message.m.senderFaceUrl,
      ));
    }
  }
}
