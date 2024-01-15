part of im_kit;

class ImLocation extends ImBase {
  const ImLocation({
    super.key,
    required super.isMe,
    required super.message,
    super.onTap,
    super.onRevokeTap,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return GestureDetector(
      onTap: () {
        onTap?.call(message);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: getSelectableView(
          context,
          Container(
            width: 220,
            color: isMe ? chatTheme.messageTheme.meBackgroundColor : chatTheme.messageTheme.backgroundColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              // des['name'] ?? '',
                              ImCore.fixAutoLines(message.ext.data?['name'] ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF333333), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              message.ext.data?['addr'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1)),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CachedImage(
                        imageUrl: message.ext.data?['url'] ?? '',
                        height: 90,
                        width: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
