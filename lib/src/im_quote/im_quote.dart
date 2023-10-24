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

  MessageExt get quoteMessage => message.ext.quoteMessage!;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getTypeWidget(context),
    );
  }

  /// 获取类型数据
  Widget getTypeWidget(BuildContext context) {
    switch (message.m.contentType) {
      case MessageType.text:
      case MessageType.at_text:
      case MessageType.quote:
        return ImAtText(
          message: quoteMessage,
          isMe: isMe,
          onClickMenu: onClickMenu,
          onTapEmail: onTapEmail,
          onTapUrl: onTapUrl,
          onTapPhone: onTapPhone,
        );
      case MessageType.picture:
        return ImImage(message: quoteMessage, isMe: isMe);
      case MessageType.file:
        return ImFile(message: quoteMessage, isMe: isMe);
      case MessageType.voice:
        return ImVoice(message: quoteMessage, isMe: isMe);
      case MessageType.video:
        return ImVideo(message: quoteMessage, isMe: isMe);
      case MessageType.card:
        return ImCard(message: quoteMessage, isMe: isMe);
      case MessageType.location:
        return ImLocation(message: quoteMessage, isMe: isMe);
      case MessageType.merger:
        return ImMerge(message: quoteMessage, isMe: isMe);
      default:
        return const Text('暂不支持的消息');
    }
  }
}
