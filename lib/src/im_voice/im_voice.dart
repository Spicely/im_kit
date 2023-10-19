part of im_kit;

class ImVoice extends ImBase {
  final void Function(MessageExt message)? onTapDownFile;

  const ImVoice({
    super.key,
    required super.isMe,
    required super.message,
    this.onTapDownFile,
  });

  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? chatTheme.messageTheme.meBackgroundColor : chatTheme.backgroundColor,
          borderRadius: chatTheme.messageTheme.borderRadius,
        ),
        child: ext.path == null
            ? const ImLoading()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: isMe ? -pi : 0,
                    child: Lottie.asset('assets/json/voice_record.json', height: 30, animate: ext.isPlaying, package: 'im_kit'),
                  ),
                  const SizedBox(width: 8),
                  Text('${message.m.soundElem?.duration}"'),
                ],
              ),
      ),
    );
  }

  /// 获取文件后缀名
  String getSuffix() {
    final String? fileName = message.m.fileElem?.fileName;
    if (fileName == null) return '';
    final List<String> list = fileName.split('.');
    return Utils.getValue(list.last, '?');
  }
}
