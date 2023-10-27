part of im_kit;

Widget _getIcon(String icon) {
  return Image.asset(icon, width: 20, height: 20);
}

List<ItemModel> _walletMenuItems(BuildContext context) {
  ImLanguage lan = ImKitTheme.of(context).language;
  return [
    ItemModel(lan.delete, _getIcon('assets/icons/delete1.png'), MenuItemType.delete),
    ItemModel(lan.multiChoice, _getIcon('assets/icons/choice.png'), MenuItemType.multiSelect),
  ];
}

List<ItemModel> _textMenuItems(BuildContext context) {
  ImLanguage lan = ImKitTheme.of(context).language;
  return [
    ItemModel(lan.copy, _getIcon('assets/icons/copy.png'), MenuItemType.copy),
    ItemModel(lan.delete, _getIcon('assets/icons/delete1.png'), MenuItemType.delete),
    ItemModel(lan.forward, _getIcon('assets/icons/forward.png'), MenuItemType.forward),
    ItemModel(lan.reply, _getIcon('assets/icons/reply.png'), MenuItemType.quote),
    ItemModel(lan.multiChoice, _getIcon('assets/icons/choice.png'), MenuItemType.multiSelect),
  ];
}

List<ItemModel> _imageMenuItems(BuildContext context) {
  ImLanguage lan = ImKitTheme.of(context).language;
  return [
    ItemModel(lan.delete, _getIcon('assets/icons/delete1.png'), MenuItemType.delete),
    ItemModel(lan.forward, _getIcon('assets/icons/forward.png'), MenuItemType.forward),
    ItemModel(lan.reply, _getIcon('assets/icons/reply.png'), MenuItemType.quote),
    ItemModel(lan.multiChoice, _getIcon('assets/icons/choice.png'), MenuItemType.multiSelect),
  ];
}

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

  /// 发送消息等待Widget
  final Widget? sendLoadingWidget;

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
  final void Function(MessageExt message)? onTapPlayVideo;

  /// 图片点击事件
  final void Function(MessageExt message)? onPictureTap;

  /// at点击事件
  final void Function(UserInfo userInfo)? onAtTap;

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  final CustomPopupMenuController _controller = CustomPopupMenuController();

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
  final Function()? onMultiSelect;

  ImListItem({
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
    this.onMultiSelect,
    this.onForwardMessage,
    this.onQuoteMessage,
    this.onResend,
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
        child: getContentType(context),
      ),
    );
  }

  Widget getContentType(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImAvatarTheme avatarTheme = ImKitTheme.of(context).chatTheme.avatarTheme;
    switch (message.m.contentType) {
      case MessageType.custom:
        switch (message.ext.data['contentType']) {
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
      case MessageType.friendApplicationApprovedNotification:
        return const Center(
          child: Text('你们已成为好友，可以开始聊天了', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
      case MessageType.memberEnterNotification:
        return Center(
          child: Text.rich(
            _getMemberEnterNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
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
        return Center(
          child: Text.rich(
            _getGroupInfoSetNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
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
      case MessageType.groupMemberMutedNotification:
        return Center(
          child: Text.rich(
            _getGroupMemberMutedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case MessageType.groupMemberCancelMutedNotification:
        return Center(
          child: Text.rich(
            _getGroupMemberCancelMutedNotification(message.ext.data, userColor: Colors.blue, onTap: onNotificationUserTap),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
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
                          onNotificationUserTap?.call(OpenIM.iMManager.uInfo!);
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
                                onTap?.call(message);
                              },
                              onDoubleTap: () {
                                onDoubleTap?.call(message);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCustomPopupMenu(
                                    context,
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
                                  ),
                                  if (message.m.contentType == MessageType.quote)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isMe ? chatTheme.messageTheme.meBackgroundColor : chatTheme.messageTheme.backgroundColor,
                                        borderRadius: chatTheme.messageTheme.borderRadius,
                                      ),
                                      margin: const EdgeInsets.only(top: 5),
                                      padding: chatTheme.messageTheme.padding,
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Wrap(
                                          children: [
                                            Text('${message.m.quoteElem?.quoteMessage?.senderNickname}：'),
                                            ImQuote(isMe: isMe, message: message),
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

  Widget _buildCustomPopupMenu(BuildContext context, Widget child) {
    /// 消息发送中不弹出功能窗口
    if (isGroupDissolution || message.m.status == MessageStatus.sending || showSelect || message.ext.isVoice) {
      return child;
    }

    /// 如果是阅后即焚消息，不显示撤回 回复 转发
    if (message.ext.isPrivateChat) {
      return child;
    }
    return CustomPopupMenu(
      controller: _controller,
      menuBuilder: () {
        return _buildLongPressMenu(context);
      },
      pressType: PressType.longPress,
      child: child,
    );
  }

  List<ItemModel> _messageMenuItems(BuildContext context) {
    if (message.m.contentType == MessageType.custom) {
      Map<String, dynamic> map = message.ext.data;
      if (map['contentType'] == 81 || map['contentType'] == 83) {
        return _walletMenuItems(context);
      }
    }
    if ([MessageType.text, MessageType.quote, MessageType.at_text].contains(message.m.contentType)) {
      return _textMenuItems(context);
    }
    if (![MessageType.text].contains(message.m.contentType)) {
      return _imageMenuItems(context);
    }
    return [];
  }

  //长按弹窗
  Widget _buildLongPressMenu(BuildContext context) {
    ImLanguage lan = ImKitTheme.of(context).language;
    List<ItemModel> menus = [..._messageMenuItems(context)];

    if (isMe) {
      if (message.m.contentType == MessageType.custom) {
        Map<String, dynamic> map = message.ext.data;
        if (map['contentType'] == 81 || map['contentType'] == 83) {
        } else {
          /// 倒数第二个是追加撤回
          menus.insert(menus.length - 1, ItemModel(lan.revoke, _getIcon('assets/icons/withdraw.png'), MenuItemType.recall));
        }
      } else {
        /// 倒数第二个是追加撤回
        menus.insert(menus.length - 1, ItemModel(lan.revoke, _getIcon('assets/icons/withdraw.png'), MenuItemType.recall));
      }
    }

    /// 如果消息还不是发送成功状态，不显示撤回 回复 转发
    if (message.m.status != MessageStatus.succeeded) {
      menus.removeWhere((element) => element.type == MenuItemType.quote || element.type == MenuItemType.forward);
    }

    List<Widget> menusList = menus
        .map(
          (item) => GestureDetector(
            onTap: () {
              _controller.hideMenu();
              switch (item.type) {
                case MenuItemType.copy:
                  String _text = '';
                  switch (message.m.contentType) {
                    case MessageType.text:
                      String? text = message.m.content;
                      if (Utils.isNotEmpty(text)) {
                        _text = EncryptExtends.DEC_STR_AES_UTF8_ZP(plainText: text!, keyStr: message.ext.secretKey);
                      }
                      break;
                    case MessageType.at_text:
                      String text = message.m.atElem?.text ?? '';
                      text = EncryptExtends.DEC_STR_AES_UTF8_ZP(plainText: text, keyStr: message.ext.secretKey);
                      message.m.atElem?.atUsersInfo?.forEach((e) {
                        text = text.replaceAll('@${e.atUserID}', '@${e.groupNickname}');
                      });
                      _text = text;
                      break;
                    case MessageType.quote:
                      String text = message.m.quoteElem?.text ?? '';
                      text = EncryptExtends.DEC_STR_AES_UTF8_ZP(plainText: text, keyStr: message.ext.secretKey);
                      _text = text;
                      break;
                  }
                  onCopyTip?.call(_text);
                  break;
                case MenuItemType.delete:

                  /// 删除消息
                  onDeleteMessage?.call(message);
                  break;
                case MenuItemType.forward:

                  /// 转发消息
                  onForwardMessage?.call(message);
                  break;
                case MenuItemType.quote:

                  /// 引用消息
                  onQuoteMessage?.call(message);
                  break;

                case MenuItemType.collect:
                  break;
                case MenuItemType.multiSelect:
                  onMultiSelect?.call();
                  break;
                case MenuItemType.recall:
                  onRevokeMessage?.call(message);
                  break;
              }
            },
            child: Container(
              width: 280 / 5,
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  item.icon,
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: menusList.length >= 5 ? 280 : 280 / 5 * menusList.length,
        color: const Color(0xFF4C4C4C),
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          crossAxisCount: menusList.length >= 5 ? 5 : menusList.length,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: menusList,
        ),
      ),
    );
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
        );
      case MessageType.picture:
        return ImImage(message: message, isMe: isMe, onTap: onPictureTap);
      case MessageType.file:
        return ImFile(message: message, isMe: isMe, onTap: onFileTap);
      case MessageType.voice:
        return ImVoice(message: message, isMe: isMe);
      case MessageType.video:
        return ImVideo(message: message, isMe: isMe, onTapDownFile: onTapDownFile, onTapPlayVideo: onTapPlayVideo);
      case MessageType.card:
        return ImCard(message: message, isMe: isMe, onTap: onCardTap);
      case MessageType.location:
        return ImLocation(message: message, isMe: isMe, onTap: onLocationTap);
      case MessageType.merger:
        return ImMerge(message: message, isMe: isMe);
      case 300:
        return ImCustomFace(message: message, isMe: isMe);
      default:
        return const Text('暂不支持的消息');
    }
  }
}
