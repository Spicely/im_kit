part of im_kit;

enum ImAtType {
  /// 文本
  text,

  /// 艾特
  at,

  /// 邮件
  email,

  /// 电话
  phone,

  /// 网址
  url,

  /// 表情
  emoji,
}

class ImAtTextType {
  AtUserInfo? userInfo;

  ImAtType type;

  String text;

  ImAtTextType({
    this.userInfo,
    required this.type,
    required this.text,
  });
}

class ImAtText extends ImBase {
  final List<MenuItemProvider>? textMenuItems;

  /// at点击事件
  final void Function(TapUpDetails details, String userID)? onAtTap;

  const ImAtText({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onClickMenu,
    this.textMenuItems,
    super.onTapUrl,
    super.onTapEmail,
    super.onTapPhone,
    this.onAtTap,
    super.contextMenuBuilder,
  });

  double get width {
    if (Utils.isMobile) {
      return showSelect ? Get.mediaQuery.size.width * 0.7 - 30 : Get.mediaQuery.size.width * 0.7;
    } else {
      return showSelect ? 470 : 500;
    }
  }

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;

    return Container(
      constraints: BoxConstraints(maxWidth: width),
      decoration: BoxDecoration(
        color: ImCore.noBgMsgType.contains(msg.contentType)
            ? null
            : isMe
                ? chatTheme.messageTheme.meBackgroundColor
                : chatTheme.messageTheme.backgroundColor,
        borderRadius: chatTheme.messageTheme.borderRadius,
      ),
      padding: ImCore.noPadMsgType.contains(msg.contentType) ? null : chatTheme.messageTheme.padding,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SelectionArea(
          contextMenuBuilder: (BuildContext context, SelectableRegionState state) {
            if (contextMenuBuilder == null) {
              return AdaptiveTextSelectionToolbar.selectableRegion(
                selectableRegionState: state,
              );
            } else {
              return contextMenuBuilder!(context, message, state);
            }
          },
          onSelectionChanged: (select) {
            ImKitIsolateManager._copyText = select?.plainText ?? '';
          },
          child: ExtendedText(
            message.ext.data,
            style: chatTheme.textStyle,
            specialTextSpanBuilder: ImExtendTextBuilder(
              allAtMap: msg.atTextElem?.atUsersInfo ?? [],
              onAtTextTap: onAtTap,
              onTapUrl: onTapUrl,
              onTapEmail: onTapEmail,
              onTapPhone: onTapPhone,
              isText: true,
            ),
          ),
        ),
      ),
    );
  }

  Color? atTypeColor(ImAtTextType info, ImChatTheme chatTheme) {
    return switch (info.type) {
      ImAtType.at => chatTheme.atTextColor,
      ImAtType.email => chatTheme.emailColor,
      ImAtType.phone => chatTheme.phoneColor,
      ImAtType.url => chatTheme.urlColor,
      _ => null,
    };
  }
}
