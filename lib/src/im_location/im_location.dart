part of im_kit;

class ImLocation extends ImBase {
  const ImLocation({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onTap,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: getSelectableView(
            context,
            Container(
              width: 220,
              color: chatTheme.messageTheme.backgroundColor,
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
                                message.ext.data?['name'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF333333), fontWeight: FontWeight.w500),
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
        Positioned(
          bottom: 4,
          right: 6,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(message.ext.time, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  if (isMe) const SizedBox(width: 1),
                  if (isMe && message.m.isRead!) const Icon(Icons.done_all, size: 12, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
