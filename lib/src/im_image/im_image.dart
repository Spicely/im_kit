part of im_kit;

class ImImage extends ImBase {
  const ImImage({
    super.key,
    required super.isMe,
    required super.message,
    required super.contextMenuController,
    super.onDeleteTap,
    super.onForwardTap,
    super.onQuoteTap,
    super.onMultiSelectTap,
    super.onRevokeTap,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;

    return Hero(
      key: message.ext.key,
      tag: ValueKey(msg.clientMsgID),
      child: GestureDetector(
        onTap: () {
          onTap?.call(message);
        },
        onLongPress: () {
          final RenderBox renderBox = message.ext.key.currentContext!.findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero); // 位置

          contextMenuController.show(
            context: context,
            contextMenuBuilder: (context) => ImAdaptiveTextSelection(
              anchors: TextSelectionToolbarAnchors(primaryAnchor: Offset(position.dx + 90, position.dy)),
              children: [
                ImAdaptiveTextItem(
                  label: language.delete,
                  icon: Image.asset('assets/icons/delete1.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onDeleteTap?.call(message);
                    contextMenuController.remove();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.forward,
                  icon: Image.asset('assets/icons/forward.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onForwardTap?.call(message);
                    contextMenuController.remove();
                  },
                ),
                ImAdaptiveTextItem(
                  label: language.reply,
                  icon: Image.asset('assets/icons/reply.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onQuoteTap?.call(message);
                    contextMenuController.remove();
                  },
                ),
                if (isMe)
                  ImAdaptiveTextItem(
                    label: language.revoke,
                    icon: Image.asset('assets/icons/withdraw.png', width: 20, height: 20, package: 'im_kit'),
                    onPressed: () {
                      onQuoteTap?.call(message);
                      contextMenuController.remove();
                    },
                  ),
                ImAdaptiveTextItem(
                  label: language.multiChoice,
                  icon: Image.asset('assets/icons/choice.png', width: 20, height: 20, package: 'im_kit'),
                  onPressed: () {
                    onMultiSelectTap?.call(message);
                    contextMenuController.remove();
                  },
                ),
              ],
            ),
          );
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
