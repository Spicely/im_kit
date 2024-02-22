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
    super.onClickMenu,
    this.textMenuItems,
    super.onTapUrl,
    super.onTapEmail,
    super.onTapPhone,
    this.onAtTap,
    super.onCopyTap,
    super.onDeleteTap,
    super.onForwardTap,
    super.onQuoteTap,
    super.onMultiSelectTap,
    super.onRevokeTap,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    var textSpan = TextSpan(
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
            ..onTapUp = (TapUpDetails details) {
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
                    onAtTap?.call(details, '-1');
                    return;
                  }
                  onAtTap?.call(details, e.userInfo!.atUserID!);
                default:
              }
            },
        );
      }
    }).toList());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SelectableText.rich(
        textSpan,
        style: chatTheme.textStyle,
        contextMenuBuilder: (BuildContext context, EditableTextState state) {
          if (contextMenuBuilder == null) {
            return AdaptiveTextSelectionToolbar.editableText(
              editableTextState: state,
            );
          } else {
            return contextMenuBuilder!(context, message, state);
          }
        },
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
