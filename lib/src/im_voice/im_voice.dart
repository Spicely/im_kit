part of im_kit;

class ImVoice extends ImBase {
  final void Function(Message message)? onTapDownFile;

  const ImVoice({
    Key? key,
    required bool isMe,
    required Message message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  ImExtModel? get ext => message.extModel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ImCore.checkFileExist(message, isMe, fileSize: message.fileElem?.fileSize),
      builder: (BuildContext context, AsyncSnapshot<(bool, ImExtModel?)> snapshot) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(color: theme.themeColor, borderRadius: theme.borderRadius),
            padding: theme.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/json/voice_record.json', height: 30, animate: ext?.isPlaying ?? false, package: 'im_kit'),
                const SizedBox(width: 8),
                Text('${message.soundElem?.duration}"'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 获取文件后缀名
  String getSuffix() {
    final String? fileName = message.fileElem?.fileName;
    if (fileName == null) return '';
    final List<String> list = fileName.split('.');
    return Utils.getValue(list.last, '?');
  }

  /// 检测文件是否存在
  /// 如果存在则名称后面加上(1)
  /// 如果存在(1)则名称后面加上(2)
  /// 以此类推
  /// 直到文件不存在为止
  /// 然后复制文件
  Future<void> saveFile(String filePath, String path, String fileName) async {
    File originFile = File(filePath);
    String copyPath = '$path/$fileName';
    File file = File(copyPath);
    if (await file.exists()) {
      int index = fileName.lastIndexOf('.');
      String suffix = fileName.substring(index);
      String name = fileName.substring(0, index);
      int i = 1;
      while (await file.exists()) {
        copyPath = '$path/$name($i)$suffix';
        file = File(copyPath);
        i++;
      }
    }
    originFile.copy(copyPath);
  }
}
