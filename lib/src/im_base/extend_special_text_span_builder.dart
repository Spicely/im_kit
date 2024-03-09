part of im_kit;
/*
 * Summary: 扩展特殊文本构建器
 * Created Date: 2023-04-11 10:51:40
 * Author: Spicely
 * -----
 * Last Modified: 2023-05-16 16:54:53
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

/// At文本点击事件
typedef AtTextCallback = Function(TapUpDetails details, String actualText);

class ImExtendTextBuilder extends SpecialTextSpanBuilder {
  final AtTextCallback? onAtTextTap;

  /// 网址点击事件
  final void Function(String)? onTapUrl;

  /// 邮箱点击事件
  final void Function(String)? onTapEmail;

  /// 电话点击事件
  final void Function(String)? onTapPhone;

  final bool isText;

  /// 引用消息删除事件
  final Function(Message msg)? onQuoteMessageDelete;

  final Message? quoteMessage;

  final List<AtUserInfo> allAtMap;

  ImExtendTextBuilder({
    required this.allAtMap,
    this.onAtTextTap,
    this.onQuoteMessageDelete,
    this.quoteMessage,
    this.isText = false,
    this.onTapUrl,
    this.onTapEmail,
    this.onTapPhone,
  });

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    StringBuffer buffer = StringBuffer();
    // if (allAtMap.isEmpty) {
    //   return TextSpan(text: data, style: textStyle);
    // }
    final List<InlineSpan> children = <InlineSpan>[];
    var regexEmoji = ImCore.emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');
    String regexFile = r'\[file:[^\]]+\]'; // Regex pattern to match [file:文件路径]
    List<String> list = [regexFile, regexEmoji];

    /// 匹配@100010#ac @100011#qa @100022#~♧^O^♤☞  的字符串
    var regexAt = allAtMap.map((e) => '@${e.atUserID} ').toList().join('|');
    if (allAtMap.isNotEmpty) {
      list.add(regexAt);
    }

    /// 匹配电话号码
    String phoneReg = r"\b\d{5,}\b";

    /// 匹配网址
    String urlRge = r'(((http(s)?:\/\/(www\.)?)|(www\.))([-a-zA-Z0-9@:;_\+.%#?&\/=]*))|([-a-zA-Z@:;_\+.%#?&\/=]{2,}\.((com)|(cn)))/g';

    /// 匹配邮箱
    String email = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
    final atReg = RegExp(regexAt);
    final fileReg = RegExp(regexFile);
    final emojiReg = RegExp(regexEmoji);
    if (isText) {
      list.addAll([email, phoneReg, urlRge]);
    }
    final pattern = '(${list.join('|')})';
    data.splitMapJoin(
      RegExp(pattern),
      onMatch: (Match m) {
        late InlineSpan inlineSpan;
        String value = m.group(0)!;
        try {
          if (emojiReg.hasMatch(value)) {
            String emoji = ImCore.emojiFaces[value]!;
            inlineSpan = ImageSpan(
              AssetImage('assets/emoji/$emoji.webp', package: 'im_kit'),
              imageWidth: 20,
              imageHeight: 20,
              start: m.start,
              actualText: value,
            );
          } else if (fileReg.hasMatch(value)) {
            inlineSpan = ImageSpan(
              FileImage(File(value.replaceFirst('[file:', '').replaceFirst(']', ''))),
              imageHeight: 100,
              imageWidth: 100,
              start: m.start,
              actualText: value,
              fit: BoxFit.cover,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: PlaceholderAlignment.bottom,
              imageAlignment: Alignment.topCenter,
            );

            buffer.write(value);
          } else if (atReg.hasMatch(value) && regexAt.isNotEmpty) {
            String id = value.split('#').first.replaceFirst('@', '').trim();
            String? name = allAtMap.firstWhereOrNull((v) => v.atUserID == id)?.groupNickname;
            if (name != null) {
              inlineSpan = SpecialTextSpan(
                text: '@$name ',
                actualText: isText ? '@$name' : value,
                start: m.start,
                style: textStyle?.copyWith(color: Colors.blue).useSystemChineseFont(),
                recognizer: TapGestureRecognizer()
                  ..onTapUp = (TapUpDetails details) {
                    onAtTextTap?.call(details, id);
                  },
              );

              buffer.write('@$name ');
            } else {
              inlineSpan = TextSpan(text: value, style: textStyle?.useSystemChineseFont());
              buffer.write(value);
            }
          } else if (RegExp(email).hasMatch(value) && isText) {
            inlineSpan = TextSpan(
              text: value,
              style: textStyle?.copyWith(color: Colors.blue).useSystemChineseFont(),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  onTapEmail?.call(value);
                },
            );
            buffer.write(value);
          } else if (RegExp(urlRge).hasMatch(value) && isText) {
            inlineSpan = TextSpan(
              text: value,
              style: textStyle?.copyWith(color: Colors.blue).useSystemChineseFont(),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  onTapUrl?.call(value);
                },
            );
            buffer.write(value);
          } else if (RegExp(phoneReg).hasMatch(value) && isText) {
            inlineSpan = TextSpan(
              text: value,
              style: textStyle?.copyWith(color: Colors.blue).useSystemChineseFont(),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  onTapPhone?.call(value);
                },
            );
            buffer.write(value);
          } else {
            inlineSpan = TextSpan(text: value, style: textStyle?.useSystemChineseFont());
            buffer.write(value);
          }
        } catch (e) {
          debugPrint('error: $e');
        }
        children.add(inlineSpan);
        return '';
      },
      onNonMatch: (text) {
        children.add(TextSpan(text: text, style: textStyle?.useSystemChineseFont()));
        buffer.write(text);
        return '';
      },
    );
    return TextSpan(children: children);
  }

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    return null;
  }
}
