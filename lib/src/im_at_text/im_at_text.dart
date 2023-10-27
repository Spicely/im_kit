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
  final void Function(UserInfo userInfo)? onAtTap;

  const ImAtText({
    super.key,
    required super.isMe,
    required super.message,
    super.onClickMenu,
    this.textMenuItems,
    super.onTapUrl,
    super.onTapEmail,
    super.onTapPhone,
    this.onAtTap,
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
              children: (message.ext.data as List<ImAtTextType>?)?.map((e) {
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
                        onTapUrl?.call(e.text);
                        break;
                      case ImAtType.email:
                        onTapEmail?.call(e.text);
                        break;
                      case ImAtType.phone:
                        onTapPhone?.call(e.text);
                        break;
                      case ImAtType.at:
                        if (e.userInfo?.atUserID == '-1') {
                          onAtTap?.call(UserInfo(userID: '-1'));
                          return;
                        }
                        if (OpenIM.iMManager.uid == e.userInfo?.atUserID) {
                          onAtTap?.call(OpenIM.iMManager.uInfo!);
                        } else {
                          OpenIM.iMManager.userManager.getUsersInfo(uidList: [e.userInfo!.atUserID!]).then((v) {
                            onAtTap?.call(v.first);
                          });
                        }
                      default:
                    }
                  },
              );
            }
          }).toList()),
          style: chatTheme.textStyle.useSystemChineseFont(),
          contextMenuBuilder: (context, editableTextState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                color: Colors.red,
              )
            ],
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
