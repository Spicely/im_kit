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
  final EdgeInsetsGeometry? padding;

  const ImQuote({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding ?? EdgeInsets.only(right: isMe ? 66 : 0, left: isMe ? 0 : 66, top: 10),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(242, 242, 242, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: getQuoteContent(context),
    );
  }

  Widget getQuoteContent(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    switch (message.m.contentType) {
      case MessageType.picture:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.picture}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.video:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.video}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

      case MessageType.merger:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.chatRecord}]${message.m.mergeElem?.title ?? ''}',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.card:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.card}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.voice:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.voice}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case 300:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.emoji}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.file:
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.file}]',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.location:
        Map<String, dynamic> des = message.ext.data;
        return Text(
          '${message.m.senderNickname ?? ''}: [${language.location}] ${des['addr']}',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.atText:
      case MessageType.quote:
      case MessageType.text:
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${message.m.senderNickname ?? ''}: ',
              ),
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
                  );
                }
              }).toList()),
            ],
          ),
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return Container();
    }
  }
}
