part of im_kit;

class ImImage extends ImBase {
  const ImImage({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onTap,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: ValueKey(msg.clientMsgID),
          child: getSelectableView(
            context,
            CachedImage(
              file: ext.file,
              width: message.ext.width,
              height: message.ext.height,
              circular: 5,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
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
              child: Text(message.m.createTime?.formatDate() ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
