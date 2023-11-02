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
typedef AtTextCallback = Function(String actualText);

class ExtendSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final AtTextCallback? onAtTextTap;

  /// 引用消息删除事件
  final Function(Message msg)? onQuoteMessageDelete;

  final Message? quoteMessage;

  final List<GroupMembersInfo> allAtMap;

  final List<GroupMembersInfo> groupMembersInfo;

  ExtendSpecialTextSpanBuilder({
    this.onAtTextTap,
    this.quoteMessage,
    this.onQuoteMessageDelete,
    required this.allAtMap,
    required this.groupMembersInfo,
  });

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    StringBuffer buffer = StringBuffer();
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }
    // if (allAtMap.isEmpty) {
    //   return TextSpan(text: data, style: textStyle);
    // }
    final List<InlineSpan> children = <InlineSpan>[];

    var regexEmoji = ImCore.emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

    /// 匹配@100010#ac @100011#qa @100022#~♧^O^♤☞  的字符串
    List<dynamic> list = [];
    var regexAt = allAtMap.map((e) => '@${e.userID}#${RegExp.escape(e.nickname!)} ').toList().join('|');
    if (allAtMap.isEmpty) {
      list = [regexEmoji];
    } else {
      list = [regexEmoji, regexAt];
    }

    final pattern = '(${list.toList().join('|')})';
    final atReg = RegExp(regexAt);
    final emojiReg = RegExp(regexEmoji);
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
          } else if (atReg.hasMatch(value)) {
            String id = value.split('#').first.replaceFirst("@", "").trim();
            String? name = allAtMap.firstWhereOrNull((v) => v.userID == id)?.nickname;
            if (name != null) {
              inlineSpan = SpecialTextSpan(
                text: '@$name ',
                actualText: value,
                start: m.start,
                style: textStyle?.copyWith(color: Colors.blue, fontSize: 16.0),
              );
              buffer.write('@$name ');
            } else {
              inlineSpan = TextSpan(text: value, style: textStyle);
              buffer.write(value);
            }
          }
          /*String id = value.replaceAll("@", "").trim();
        if (allAtMap.containsKey(id)) {
          var name = allAtMap[id]!;
          inlineSpan = ExtendedWidgetSpan(
            child: Text('@$name ', style: atStyle),
            style: atStyle,
            actualText: '$value',
            start: m.start,
          );
          buffer.write('@$name ');
        }*/
          else {
            /* inlineSpan = SpecialTextSpan(
            text: '${m.group(0)}',
            style: TextStyle(color: Colors.blue),
            start: m.start,
          );*/
            inlineSpan = TextSpan(text: value, style: textStyle);
            buffer.write(value);
          }
        } catch (e) {
          print('error: $e');
        }
        children.add(inlineSpan);
        return "";
      },
      onNonMatch: (text) {
        children.add(TextSpan(text: text, style: textStyle));
        buffer.write(text);
        return '';
      },
    );
    return TextSpan(children: children, style: textStyle);
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
