part of im_kit;

class ImImage extends ImBase {
  const ImImage({
    super.key,
    required super.isMe,
    required super.message,
    super.onDeleteTap,
    super.onForwardTap,
    super.onQuoteTap,
    super.onMultiSelectTap,
    super.onRevokeTap,
    super.onTap,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      key: message.ext.key,
      tag: ValueKey(msg.clientMsgID),
      child: getSelectableView(
        context,
        GestureDetector(
          onTap: () {
            onTap?.call(message);
          },
          child: CachedImage(
            imageUrl: msg.pictureElem?.snapshotPicture?.url,
            file: ext.file,
            width: message.ext.width,
            height: message.ext.height,
            circular: 5,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
