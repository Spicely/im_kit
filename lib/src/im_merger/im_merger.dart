part of im_kit;

class ImMerge extends ImBase {
  const ImMerge({
    Key? key,
    required bool isMe,
    required MessageExt message,
  }) : super(key: key, isMe: isMe, message: message);

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: chatTheme.messageTheme.borderRadius,
        color: const Color.fromRGBO(247, 247, 247, 1),
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(_fixAutoLines(msg.mergeElem?.title ?? ''), softWrap: true, maxLines: 1, textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          ...msg.mergeElem?.abstractList
                  ?.map((e) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: _getEmoji(e, style: const TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1), height: 1.6), maxLines: 1, fontSize: 10),
                      ))
                  .toList() ??
              [],
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color.fromRGBO(151, 151, 151, 0.14)),
          Container(
            alignment: Alignment.centerLeft,
            height: 22,
            child: const Text(
              '聊天记录',
              style: TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1)),
            ),
          )
        ],
      ),
    );
  }
}
