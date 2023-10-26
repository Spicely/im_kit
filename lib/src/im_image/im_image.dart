part of im_kit;

class ImImage extends ImBase {
  const ImImage({
    super.key,
    required super.isMe,
    required super.message,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print(message.ext.width);
    return Hero(
      tag: ValueKey(msg.clientMsgID),
      child: GestureDetector(
        onTap: () {
          onTap?.call(message);
        },
        child: CachedImage(
          file: ext.path != null ? File(ext.path!) : null,
          width: message.ext.width,
          height: message.ext.height,
          circular: 5,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
