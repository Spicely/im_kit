part of im_kit;

class ImVoice extends ImBase {
  final void Function(MessageExt message)? onTapDownFile;

  const ImVoice({
    Key? key,
    required bool isMe,
    required MessageExt message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(color: theme.themeColor, borderRadius: theme.borderRadius),
        padding: theme.padding,
        child: ext.path == null
            ? const ImLoading()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/json/voice_record.json', height: 30, animate: ext.isPlaying, package: 'im_kit'),
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
