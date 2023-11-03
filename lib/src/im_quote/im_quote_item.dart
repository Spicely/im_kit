part of im_kit;

class ImQuoteItem extends ImBase {
  const ImQuoteItem({
    super.key,
    required super.isMe,
    required super.message,
    required super.contextMenuController,
    super.onRevokeTap,
  });

  MessageExt get quoteMsg => message.ext.quoteMessage!;

  double get maxW {
    if ((quoteMsg.m.contentType == MessageType.location) || (quoteMsg.m.contentType == MessageType.file) || (quoteMsg.m.contentType == MessageType.card)) {
      return 180;
    }
    return 228;
  }

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    String? filename = quoteMsg.m.fileElem?.fileName;

    /// 获取文件后缀名
    String? suffix = filename?.substring(filename.lastIndexOf('.') + 1, filename.length);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: chatTheme.messageTheme.padding,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(242, 242, 242, 1),
        borderRadius: chatTheme.messageTheme.borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxW),
            // constraints: BoxConstraints(maxWidth: Get.width - 240.sp),
            child: getQuoteContent(context),
          ),
          if (quoteMsg.m.contentType == MessageType.location)
            Row(
              children: [
                const SizedBox(width: 4),
                CachedImage(imageUrl: message.ext.data['url'] ?? '', height: 30, width: 30, circular: 2, fit: BoxFit.cover),
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
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: suffix == null ? Image.asset('assets/icons/query.png', width: 20, height: 20) : Text(suffix, style: const TextStyle(fontSize: 10, color: Colors.white)),
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
                CachedImage(imageUrl: json.decode(quoteMsg.m.content!)['faceURL'] ?? '', height: 30, width: 30, circular: 4, fit: BoxFit.cover),
              ],
            ),
        ],
      ),
    );
  }

  List<AtUserInfo> get atUsersInfo => quoteMsg.m.atElem?.atUsersInfo ?? [];

  Widget getQuoteContent(BuildContext context) {
    Color gray = const Color.fromRGBO(126, 126, 126, 1);
    ImLanguage language = ImKitTheme.of(context).language;
    switch (quoteMsg.m.contentType) {
      case MessageType.picture:
        PictureElem? pictureElem = quoteMsg.m.pictureElem;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quoteMsg.m.senderNickname ?? ''}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            CachedImage(
              width: 40,
              height: 40,
              circular: 0,
              file: pictureElem?.sourcePath != null ? File(pictureElem!.sourcePath!) : null,
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
              '${quoteMsg.m.senderNickname ?? ''}: ',
              style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 4),
            // ImVoice(message: message, controller: serverData),
          ],
        );
      case MessageType.video:
        VideoElem? sourcePicture = quoteMsg.m.videoElem;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${quoteMsg.m.senderNickname ?? ''}: ',
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
                      child: Image.network(sourcePicture?.snapshotUrl ?? '', width: 40, height: 40, fit: BoxFit.cover),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Image.asset('assets/images/ic_video_play.webp', width: 15),
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
          ImCore.fixAutoLines('${quoteMsg.m.senderNickname ?? ''}: [${language.chatRecord}] ${quoteMsg.m.mergeElem?.title ?? ''}'),
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
              '${quoteMsg.m.senderNickname ?? ''}: ',
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
          ImCore.fixAutoLines('${quoteMsg.m.senderNickname ?? ''}: ${data['nickname']}'),
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

      case MessageType.file:
        return Text(
          ImCore.fixAutoLines('${quoteMsg.m.senderNickname ?? ''}: ${quoteMsg.m.fileElem?.fileName ?? ''}'),
          style: TextStyle(fontSize: 12, color: gray),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.location:
        Map<String, dynamic> des = quoteMsg.ext.data;
        return Text(
          ImCore.fixAutoLines('${quoteMsg.m.senderNickname ?? ''}: ${des['addr']}'),
          style: TextStyle(fontSize: 12, color: gray),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageType.at_text:
      case MessageType.quote:
      case MessageType.text:
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${quoteMsg.m.senderNickname ?? ''}: ',
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
                  return TextSpan(text: e.text);
                }
              }).toList()),
            ],
          ),
          style: const TextStyle(fontSize: 12, color: Color.fromRGBO(126, 126, 126, 1)),
        );

      default:
        return Container();
    }
  }
}