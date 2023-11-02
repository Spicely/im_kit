part of im_kit;

class ImCustomFace extends ImBase {
  const ImCustomFace({
    super.key,
    required super.isMe,
    required super.message,
    required super.contextMenuController,
    super.onRevokeTap,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImage(
      file: ext.file,
      width: message.ext.width,
      height: message.ext.height,
      fit: BoxFit.cover,
    );
  }
}
