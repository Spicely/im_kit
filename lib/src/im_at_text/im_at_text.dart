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
    super.onCopyTap,
    super.onDeleteTap,
    super.onForwardTap,
    super.onQuoteTap,
    super.onMultiSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    ImLanguage language = ImKitTheme.of(context).language;
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
            contextMenuBuilder: (context, editableTextState) => ImAdaptiveTextSelection(
              anchors: editableTextState.contextMenuAnchors,
              children: [
                ImAdaptiveTextItem(
                  label: language.copy,
                  icon: Image.asset('assets/icons/copy.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    if (onCopyTap == null) {
                      /// 获取选中的文字
                      String text = editableTextState.textEditingValue.text.substring(editableTextState.textEditingValue.selection.baseOffset, editableTextState.textEditingValue.selection.extentOffset);
                      Clipboard.setData(ClipboardData(text: text));
                    } else {
                      onCopyTap?.call(editableTextState);
                    }
                    editableTextState.hideToolbar();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.delete,
                  icon: Image.asset('assets/icons/delete1.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onDeleteTap?.call(message);
                    editableTextState.hideToolbar();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.forward,
                  icon: Image.asset('assets/icons/forward.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onForwardTap?.call(message);
                    editableTextState.hideToolbar();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.reply,
                  icon: Image.asset('assets/icons/reply.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onQuoteTap?.call(message);
                    editableTextState.hideToolbar();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.multiChoice,
                  icon: Image.asset('assets/icons/choice.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onMultiSelectTap?.call(message);
                    editableTextState.hideToolbar();
                  },
                ),
              ],
            ),
          ),
        ));
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
