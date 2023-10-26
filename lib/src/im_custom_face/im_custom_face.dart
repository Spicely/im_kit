part of im_kit;

class ImCustomFace extends ImBase {
  const ImCustomFace({
    super.key,
    required super.isMe,
    required super.message,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImage(
      file: ext.path != null ? File(ext.path!) : null,
      width: message.ext.width,
      height: message.ext.height,
      circular: 5,
      fit: BoxFit.cover,
    );
  }
}
