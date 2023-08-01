part of im_kit;

class ImListItem extends StatelessWidget {
  final MessageExt message;

  final void Function(MessageExt message)? onTapDownFile;

  final void Function(MessageExt message)? onTap;

  const ImListItem({
    super.key,
    required this.message,
    this.onTapDownFile,
    this.onTap,
  });

  bool get isMe => message.m.sendID == OpenIM.iMManager.uid;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImage(imageUrl: message.m.senderFaceUrl, width: 35, height: 35, circular: 5, fit: BoxFit.cover),
            const SizedBox(width: 10),
            // Container(
            //   color: Colors.white,
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            //   child:
            // ),
            GestureDetector(
              onTap: () {
                onTap?.call(message);
              },
              child: getTypeWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTypeWidget() {
    switch (message.m.contentType) {
      case MessageType.text:
      case MessageType.at_text:
        return ImAtText(message: message, isMe: isMe);
      case MessageType.picture:
        return ImImage(message: message, isMe: isMe);
      case MessageType.file:
        return ImFile(message: message, isMe: isMe, onTapDownFile: onTapDownFile);
      case MessageType.voice:
        return ImVoice(message: message, isMe: isMe);
      case MessageType.video:
        return ImVideo(message: message, isMe: isMe);
      default:
        return const Text('暂不支持的消息');
    }
  }
}
