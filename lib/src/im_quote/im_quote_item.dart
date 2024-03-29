part of im_kit;

class ImQuoteItem extends ImBase {
  /// 语音点击事件
  final void Function(MessageExt message)? onVoiceTap;

  const ImQuoteItem({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onQuoteMessageTap,
    super.contextMenuBuilder,
    super.onDoubleTap,
    this.onVoiceTap,
    super.onLocationTap,
  });

  MessageExt get quoteMsg => message.ext.quoteMessage!
    ..ext.file = message.ext.file
    ..ext.previewFile = ext.previewFile;

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;

    return GestureDetector(
      onTap: () {
        onQuoteMessageTap?.call(message);
      },
      child: Directionality(
        textDirection: isMe ? TextDirection.ltr : TextDirection.ltr,
        child: Container(
          padding: chatTheme.messageTheme.quotePadding,
          decoration: BoxDecoration(
            color: chatTheme.messageTheme.backgroundColor,
            borderRadius: chatTheme.messageTheme.borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: getQuoteContent(context),
              ),
              if (quoteMsg.m.contentType == MessageType.location)
                GestureDetector(
                  onTap: () {
                    onLocationTap?.call(quoteMsg);
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      CachedImage(imageUrl: quoteMsg.ext.data?['url'] ?? '', height: 30, width: 30, circular: 2, fit: BoxFit.cover),
                    ],
                  ),
                ),
              if (quoteMsg.m.contentType == MessageType.card)
                Row(
                  children: [
                    const SizedBox(width: 4),
                    CachedImage(imageUrl: quoteMsg.ext.data?['faceURL'] ?? '', height: 30, width: 30, circular: 4, fit: BoxFit.cover),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<AtUserInfo> get atUsersInfo => quoteMsg.m.atTextElem?.atUsersInfo ?? [];

  Widget getQuoteContent(BuildContext context) {
    Color gray = const Color.fromRGBO(126, 126, 126, 1);
    ImLanguage language = ImKitTheme.of(context).language;
    switch (quoteMsg.m.contentType) {
      case MessageType.picture:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quoteMsg.m.name}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            CachedImage(
              width: 40,
              height: 40,
              circular: 0,
              file: quoteMsg.ext.file,
              fit: BoxFit.cover,
            )
          ],
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${quoteMsg.m.name}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            ImVoice(
              message: quoteMsg,
              isMe: true,
              showSelect: showSelect,
              showBackground: false,
              onTap: onVoiceTap,
              contextMenuBuilder: contextMenuBuilder,
            ),
          ],
        );
      case MessageType.video:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quoteMsg.m.name}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedImage(file: ext.previewFile, width: 40, height: 40, circular: 5),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
          ],
        );

      case MessageType.merger:
        return Text(
          '${quoteMsg.m.name}: [${language.chatRecord}] ${quoteMsg.m.mergeElem?.title ?? ''}',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case 300:
        Map<String, dynamic> map = quoteMsg.ext.data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quoteMsg.m.name}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            CachedImage(width: 40, imageUrl: map['url'], fit: BoxFit.cover),
          ],
        );
      case MessageType.card:
        var data = quoteMsg.ext.data;
        return Text(
          '${quoteMsg.m.name}: ${data['nickname']}',
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${quoteMsg.m.name}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            ImFile(
              isMe: isMe,
              message: quoteMsg,
              showSelect: false,
              contextMenuBuilder: contextMenuBuilder,
              showBackground: false,
              onDoubleTap: onDoubleTap,
            ),
          ],
        );
      case MessageType.location:
        Map<String, dynamic> des = quoteMsg.ext.data;
        return Text(
          '${quoteMsg.m.name}: ${des['addr']}',
          style: TextStyle(fontSize: 12, color: gray),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.atText:
      case MessageType.quote:
      case MessageType.text:
        TextSpan span = TextSpan(
          children: [
            TextSpan(
              text: '${quoteMsg.m.name}: ',
            ),
            TextSpan(
                children: (quoteMsg.ext.data as List<ImAtTextType>?)?.map((e) {
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
                return TextSpan(text: ImCore.fixAutoLines(e.text));
              }
            }).toList()),
          ],
        );
        return Text.rich(
          span,
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          textAlign: TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

      default:
        return Container();
    }
  }
}
