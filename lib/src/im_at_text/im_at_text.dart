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

  const ImAtText({
    super.key,
    required super.isMe,
    required super.message,
    super.onClickMenu,
    this.textMenuItems,
    super.onUrlTap,
    super.onEmailTap,
    super.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return GestureDetector(
      onLongPress: textMenuItems == null
          ? null
          : () {
              // onShow(context);
            },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SelectableText.rich(
          TextSpan(
              children: (message.ext.data as List<ImAtTextType>).map((e) {
            if (e.type == ImAtType.emoji) {
              return WidgetSpan(
                child: CachedImage(
                  assetUrl: 'assets/emoji/${e.text}.webp',
                  width: 25,
                  height: 25,
                  package: 'im_kit',
                ),
              );
            } else {
              return TextSpan(
                text: e.text,
                style: TextStyle(color: atTypeColor(e, chatTheme)),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    switch (e.type) {
                      case ImAtType.url:
                        onUrlTap?.call(e.text);
                        break;
                      case ImAtType.email:
                        onEmailTap?.call(e.text);
                        break;
                      case ImAtType.phone:
                        onPhoneTap?.call(e.text);
                        break;
                      default:
                    }
                  },
              );
            }
          }).toList()),
          style: chatTheme.textStyle.useSystemChineseFont(),
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

  void onShow(BuildContext context) {
    // PopupMenu menu = PopupMenu(
    //   context: context,
    //   items: textMenuItems!,
    //   onClickMenu: (item) {
    //     onClickMenu?.call(item, message);
    //   },
    //   config: const MenuConfig(itemHeight: 40),
    //   onDismiss: () {},
    // );
    // menu.show(widgetKey: message.ext.itemKey);
  }
}
