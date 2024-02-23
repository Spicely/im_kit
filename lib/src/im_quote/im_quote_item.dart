part of im_kit;

class ImQuoteItem extends ImBase {
  const ImQuoteItem({
    super.key,
    required super.isMe,
    required super.message,
    super.onQuoteMessageTap,
    super.onRevokeTap,
  });

  MessageExt get quoteMsg => message.ext.quoteMessage!
    ..ext.file = message.ext.file
    ..ext.previewFile = ext.previewFile;

  double get maxW {
    if ((quoteMsg.m.contentType == MessageType.location) || (quoteMsg.m.contentType == MessageType.file) || (quoteMsg.m.contentType == MessageType.card)) {
      return 180;
    }
    return 400;
  }

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    String? filename = quoteMsg.m.fileElem?.fileName;

    /// 获取文件后缀名
    String? suffix = filename?.substring(filename.lastIndexOf('.') + 1, filename.length);

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
                constraints: BoxConstraints(maxWidth: maxW),
                child: getQuoteContent(context),
              ),
              if (quoteMsg.m.contentType == MessageType.location)
                Row(
                  children: [
                    const SizedBox(width: 4),
                    CachedImage(imageUrl: message.ext.data?['url'] ?? '', height: 30, width: 30, circular: 2, fit: BoxFit.cover),
                  ],
                ),
              if (quoteMsg.m.contentType == MessageType.file)
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Stack(
                      children: [
                        const CachedImage(
                          width: 30,
                          height: 30,
                          assetUrl: 'assets/icons/msg_default.png',
                          package: 'im_kit',
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: suffix == null
                                ? Image.asset(
                                    'assets/icons/query.png',
                                    width: 20,
                                    height: 20,
                                    package: 'im_kit',
                                  )
                                : Text(suffix, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              if (quoteMsg.m.contentType == MessageType.card)
                Row(
                  children: [
                    const SizedBox(width: 4),
                    CachedImage(imageUrl: json.decode(quoteMsg.m.textElem!.content!)['faceURL'] ?? '', height: 30, width: 30, circular: 4, fit: BoxFit.cover),
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
            // ImVoice(message: message, controller: serverData),
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
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => ImPlayer(message: quoteMsg),
                  ),
                );
              },
              child: SizedBox(
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
            )
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
        return Text(
          '${quoteMsg.m.name}: ${quoteMsg.m.fileElem?.fileName ?? ''}',
          style: TextStyle(fontSize: 12, color: gray),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
        return Text.rich(
          TextSpan(
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
          ),
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
