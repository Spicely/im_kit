part of im_kit;

class ImCustomFace extends ImBase {
  const ImCustomFace({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return getSelectableView(
      context,
      CachedImage(
        file: ext.file,
        width: message.ext.width,
        height: message.ext.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
