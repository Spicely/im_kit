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

  List<ImAtTextType> get text {
    String v = message.m.atElem?.text ?? message.m.atElem?.text ?? message.m.content ?? '';

    List<ImAtTextType> list = [];

    /// 匹配艾特用户
    String atReg = atUsersInfo.map((v) => '@${v.atUserID} ').join('|');

    /// 匹配电话号码
    String phoneReg = r"\b\d{5,}\b";

    /// 匹配网址
    String urlRge = r'(((http(s)?:\/\/(www\.)?)|(www\.))([-a-zA-Z0-9@:;_\+.%#?&\/=]*))|([-a-zA-Z@:;_\+.%#?&\/=]{2,}\.((com)|(cn)))/g';

    /// 匹配邮箱
    String email = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
    String regExp;
    if (atUsersInfo.isEmpty) {
      regExp = [urlRge, email, phoneReg].join('|');
    } else {
      regExp = [urlRge, atReg, email, phoneReg].join('|');
    }
    v.splitMapJoin(
      RegExp('($regExp)'),
      onMatch: (Match m) {
        String value = m.group(0)!;
        if (RegExp(urlRge).hasMatch(value)) {
          list.add(ImAtTextType(type: ImAtType.url, text: value.trimRight()));
        } /*else if (RegExp(regexEmoji).hasMatch(value)) {
          String emoji = emojiFaces[value]!;
          list.add(ImAtTextType(type: ImAtType.emoji, text: emoji));
        } */
        else if (RegExp(email).hasMatch(value)) {
          list.add(ImAtTextType(type: ImAtType.email, text: value));
        } else if (RegExp(atReg).hasMatch(value)) {
          String id = value.replaceAll('@', '').trim();
          AtUserInfo? atUserInfo = atUsersInfo.firstWhereOrNull((v) => v.atUserID == id);
          if (atUserInfo == null) {
            if (RegExp(phoneReg).hasMatch(value)) {
              list.add(ImAtTextType(type: ImAtType.phone, text: value));
            } else {
              list.add(ImAtTextType(type: ImAtType.text, text: value));
            }
          } else {
            if (atUserInfo.atUserID == OpenIM.iMManager.uid) {
              list.add(ImAtTextType(type: ImAtType.at, text: '@你 ', userInfo: atUserInfo));
            } else {
              list.add(ImAtTextType(type: ImAtType.at, text: '@${atUserInfo.groupNickname} ', userInfo: atUserInfo));
            }
          }
        } else if (RegExp(phoneReg).hasMatch(value)) {
          list.add(ImAtTextType(type: ImAtType.phone, text: value));
        }
        return '';
      },
      onNonMatch: (String n) {
        list.add(ImAtTextType(type: ImAtType.text, text: n));
        return '';
      },
    );

    return list;
  }

  List<AtUserInfo> get atUsersInfo => message.m.atElem?.atUsersInfo ?? [];

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
    return GestureDetector(
      onLongPress: textMenuItems == null
          ? null
          : () {
              // onShow(context);
            },
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? theme.chatTheme.meBackgroundColor ?? Theme.of(context).primaryColor : theme.chatTheme.backgroundColor,
          borderRadius: theme.chatTheme.borderRadius,
        ),
        padding: theme.chatTheme.padding,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SelectableText.rich(
            TextSpan(
                children: text
                    .map(
                      (e) => TextSpan(
                        text: e.text,
                        style: TextStyle(color: atTypeColor(e)),
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
                      ),
                    )
                    .toList()),
            style: theme.chatTheme.textStyle.useSystemChineseFont(),
          ),
        ),
      ),
    );
  }

  Color? atTypeColor(ImAtTextType info) {
    return switch (info.type) {
      ImAtType.at => theme.chatTheme.atTextColor,
      ImAtType.email => theme.chatTheme.emailColor,
      ImAtType.phone => theme.chatTheme.phoneColor,
      ImAtType.url => theme.chatTheme.urlColor,
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
