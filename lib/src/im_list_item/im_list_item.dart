part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(MessageExt message)? onTapDownFile;

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

  /// 合并消息点击
  final void Function(MessageExt message)? onMergerTap;

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

  /// 重新编辑点击事件
  final void Function(MessageExt message)? onReEditTap;

  /// 点击播放视频
  final void Function(MessageExt message)? onTapPlayVideo;

  /// 图片点击事件
  final void Function(MessageExt message)? onPictureTap;

  /// at点击事件
  final void Function(TapUpDetails details, String userID)? onAtTap;

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  /// 是否显示选择按钮
  final bool showSelect;

  /// 不允许通过群获取成员资料
  final bool lookMemberInfo;

  /// 文件保存之后
  final Function(bool status)? onAfterSave;

  /// tag点击事件
  final Function(String userID)? onTagUserTap;

  /// 复制消息提示事件
  final Function(String text)? onCopyTip;

  /// 重新发送事件
  final Function(MessageExt extMsg)? onResend;

  /// 引用消息点击
  final void Function(MessageExt message)? onQuoteMessageTap;

  /// 语音点击事件
  final void Function(MessageExt message)? onVoiceTap;

  /// 头像点击事件
  final void Function(TapUpDetails details, String userID)? onAvatarTap;

  /// 头像右键点击事件
  final void Function(Offset position, String userID)? onAvatarRightTap;

  /// 头像长按事件
  final void Function(String userID)? onAvatarLongPress;

  /// 双击点击消息体
  final void Function(MessageExt message)? onDoubleTapFile;

  final Widget Function(BuildContext, MessageExt, EditableTextState)? contextMenuBuilder;

  /// 是否显示通知类消息
  final bool showNotification;

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
    this.onAfterSave,
    this.onTagUserTap,
    this.onCopyTip,
    this.onResend,
    this.onMergerTap,
    this.onMessageSelect,
    this.onQuoteMessageTap,
    this.highlight = false,
    this.onVoiceTap,
    this.onAvatarTap,
    this.onAvatarLongPress,
    this.onAvatarRightTap,
    this.onDoubleTapFile,
    this.contextMenuBuilder,
    this.showNotification = true,
    this.onReEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight ? Colors.blue.withOpacity(0.1) : null,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          if (message.ext.showTime && showNotification) ImTime(message: message),
          Row(
            children: [
              if (showSelect && !ImCore.types.contains(message.m.contentType))
                Row(
                  children: [
                    Checkbox(
                      value: selected,
                      splashRadius: 0,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        width: 1.2,
                        color: message.m.status != MessageStatus.succeeded || message.ext.isVoice || message.ext.isRedEnvelope ? const Color.fromRGBO(175, 175, 175, 0.2) : const Color.fromRGBO(175, 175, 175, 1),
                      ),
                      fillColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? Theme.of(context).primaryColor : Colors.transparent),
                      onChanged: message.m.status != MessageStatus.succeeded || message.ext.isVoice || message.ext.isRedEnvelope
                          ? null
                          : (value) {
                              onMessageSelect?.call(message, !selected);
                            },
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              Expanded(
                child: Directionality(
                  textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: getContentType(context),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget beforeRenderView(Widget child) {
    if (showNotification) return child;
    return const SizedBox();
  }

  Widget getContentType(BuildContext context) {
    ImAvatarTheme avatarTheme = ImKitTheme.of(context).chatTheme.avatarTheme;

    return switch (message.m.contentType) {
      MessageType.custom => switch (message.ext.data['contentType']) {
          27 => beforeRenderView(const Center(child: Text.rich(TextSpan(text: '双方聊天记录已清空'), style: TextStyle(fontSize: 12, color: Colors.grey)))),
          77 => beforeRenderView(const Center(child: Text.rich(TextSpan(text: '群主清除了聊天记录'), style: TextStyle(fontSize: 12, color: Colors.grey)))),
          81 => ImRedEnv(isMe: isMe, message: message, showSelect: showSelect),
          82 => beforeRenderView(
              Center(
                child: Text.rich(
                  _getRedEnvelope(message, message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          2024 => beforeRenderView(const Center(child: Text.rich(TextSpan(text: '对方不是你的好友'), style: TextStyle(fontSize: 12, color: Colors.grey)))),
          2025 => beforeRenderView(const Center(child: Text.rich(TextSpan(text: '对方拒收你的消息'), style: TextStyle(fontSize: 12, color: Colors.grey)))),
          _ => beforeRenderView(
              const Center(child: Text('暂不支持的消息', style: TextStyle(fontSize: 12, color: Colors.grey))),
            )
        },
      MessageType.groupMutedNotification => beforeRenderView(
          const Center(child: Text('群组开启禁言', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ),
      MessageType.groupCancelMutedNotification => beforeRenderView(
          const Center(child: Text('群组取消禁言', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ),
      MessageType.friendAddedNotification || MessageType.friendApplicationApprovedNotification => beforeRenderView(
          const Center(child: Text('你们已成为好友，可以开始聊天了', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ),
      MessageType.encryptedNotification => beforeRenderView(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/lock.png', width: 16, height: 16, package: 'im_kit'),
                  const Text('消息和通话记录都会进行端到端加密，任何人或者组织都无法读取或收听', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      MessageType.memberKickedNotification => beforeRenderView(
          Center(
            child: Text.rich(
              _getMemberKickedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      MessageType.burnAfterReadingNotification => beforeRenderView(Center(
          child: Text(
            message.ext.data?['isPrivate'] == true ? '阅后即焚已开启' : '阅后即焚已关闭',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        )),
      MessageType.revoke => beforeRenderView(
          Center(
            child: Text.rich(
              _getRevoke(message, userColor: Colors.blue, onTap: onNotificationUserTap, onReEditTap: onReEditTap),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      MessageType.groupOwnerTransferredNotification ||
      MessageType.groupInfoSetNotification ||
      MessageType.groupCreatedNotification ||
      MessageType.groupMemberCancelMutedNotification ||
      MessageType.groupMemberMutedNotification ||
      MessageType.memberEnterNotification ||
      MessageType.memberQuitNotification =>
        Center(
          child: beforeRenderView(
            Text.rich(
              _getNotification(message.ext.data, message.m.contentType!, userColor: Colors.blue, onTap: onNotificationUserTap),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      MessageType.memberInvitedNotification => beforeRenderView(
          Center(
            child: Text.rich(
              _getMemberInvitedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      _ => GestureDetector(
          onTap: _onSelectTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Listener(
                onPointerDown: (PointerDownEvent event) {
                  if (event.buttons == 2 && message.m.isGroupChat) {
                    onAvatarRightTap?.call(event.position, message.m.sendID!);
                  }
                },
                child: GestureDetector(
                  onTapUp: _onAvatarTap,
                  onLongPress: _onAvatarLongPress,
                  child: CachedImage(
                    imageUrl: message.m.senderFaceUrl,
                    width: avatarTheme.width,
                    height: avatarTheme.height,
                    circular: avatarTheme.circular,
                    fit: avatarTheme.fit,
                    filterQuality: FilterQuality.high,
                  ),
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
                            // onTap: _onTap,
                            onDoubleTap: () {
                              onDoubleTap?.call(message);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    getTypeWidget(),
                                    const SizedBox(width: 10),
                                    SizedBox(child: getStatusWidget()),
                                  ],
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
                                if (message.m.contentType == MessageType.quote || (message.m.contentType == MessageType.at_text && message.m.quoteElem != null) && message.ext.quoteMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 5),
                                    child: ImQuoteItem(
                                      isMe: isMe,
                                      message: message,
                                      showSelect: showSelect,
                                      onQuoteMessageTap: onQuoteMessageTap,
                                      onVoiceTap: onVoiceTap,
                                      contextMenuBuilder: contextMenuBuilder,
                                      onDoubleTap: onDoubleTapFile,
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
              ),
            ],
          ),
        )
    };
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
      case MessageType.at_text:
      case MessageType.quote:
        return ImAtText(
          message: onBuildBeforeMsg != null ? onBuildBeforeMsg!.call(message) : message,
          isMe: isMe,
          showSelect: showSelect,
          onClickMenu: onClickMenu,
          textMenuItems: textMenuItems,
          onTapEmail: onTapEmail,
          onTapUrl: onTapUrl,
          onTapPhone: onTapPhone,
          onAtTap: onAtTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.picture:
        return ImImage(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
          onTap: onPictureTap,
          contextMenuBuilder: contextMenuBuilder,
        );

      case MessageType.file:
        return ImFile(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
          onTap: onFileTap,
          onDoubleTap: onDoubleTapFile,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.voice:
        return ImVoice(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
          onTap: onVoiceTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.video:
        return Stack(
          children: [
            ImVideo(
              message: message,
              showSelect: showSelect,
              isMe: isMe,
              onTapDownFile: onTapDownFile,
              onTapPlayVideo: onTapPlayVideo,
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
          showSelect: showSelect,
          isMe: isMe,
          onTap: onCardTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.location:
        return ImLocation(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
          onTap: onLocationTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case MessageType.merger:
        return ImMerge(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
          onTap: onMergerTap,
          contextMenuBuilder: contextMenuBuilder,
        );
      case 300:
        return ImCustomFace(
          message: message,
          showSelect: showSelect,
          isMe: isMe,
        );
      default:
        return const Text('暂不支持的消息');
    }
  }

  void _onTap() {
    _onSelectTap();
    // onTap?.call(message);
    // switch (message.m.contentType) {
    //   case MessageType.voice:
    //     onVoiceTap?.call(message);
    //     break;
    // }
  }

  /// 头像点击
  void _onAvatarTap(TapUpDetails details) {
    onAvatarTap?.call(details, message.m.sendID!);
  }

  /// 头像长按
  void _onAvatarLongPress() {
    onAvatarLongPress?.call(message.m.sendID!);
  }
}
