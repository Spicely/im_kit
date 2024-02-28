part of im_kit;

class ImVoice extends ImBase {
  const ImVoice({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.contextMenuBuilder,
    super.onTap,
    super.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: getSelectableView(
        context,
        Row(
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
