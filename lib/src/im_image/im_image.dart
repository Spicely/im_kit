part of im_kit;

class ImImage extends ImBase {
  /// 图片点击事件
  final void Function(MessageExt message)? onTapPicture;

  const ImImage({
    super.key,
    required super.isMe,
    required super.message,
    this.onTapPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: ValueKey(msg.clientMsgID),
      child: GestureDetector(
        onTap: () {
          onTapPicture?.call(message);
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
