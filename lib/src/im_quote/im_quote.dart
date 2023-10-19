part of im_kit;
/*
 * Summary: 引用回复消息
 * Created Date: 2023-03-21 13:49:52
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-16 17:22:13
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class ImQuote extends ImBase {
  const ImQuote({
    Key? key,
    required bool isMe,
    required MessageExt message,
  }) : super(key: key, isMe: isMe, message: message);

  Message? get quoteMsg => msg.quoteElem?.quoteMessage;

  String get regexEmoji => _emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

  List<AtUserInfo> get atUsersInfo => msg.atElem?.atUsersInfo ?? [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ImAtText(isMe: isMe, message: message.m.quoteElem!.quoteMessage!.toExt(message.ext.secretKey)),
    );
  }
}
