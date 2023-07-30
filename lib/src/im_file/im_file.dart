part of im_kit;

class ImFile extends ImBase {
  final void Function(Message message)? onTapDownFile;

  const ImFile({
    Key? key,
    required bool isMe,
    required Message message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  ImExtModel? get ext => message.ext;

  /// 检测文件是否存在
  Future<(bool, ImExtModel?)> checkFileExist(Message msg, {int? fileSize}) async {
    /// 本地文件
    if (msg.fileElem?.filePath != null && isMe) {
      File file = File(msg.fileElem!.filePath!);
      bool status = file.existsSync();
      if (!status) return (false, null);
      if (fileSize != null) {
        int size = await file.length();
        if (size != fileSize) {
          return (false, null);
        }
      }
      return (true, ImExtModel(path: msg.fileElem!.filePath!));
    }
    String? url = msg.fileElem?.sourceUrl;
    if (url == null) return (false, null);
    String fileName = url.split('/').last;
    String filePath = join(ImCore.dirPath, 'FileRecv', OpenIM.iMManager.uid, fileName);
    bool status = File(filePath).existsSync();
    if (!status) return (false, null);
    if (fileSize != null) {
      File file = File(filePath);
      int size = await file.length();
      if (size != fileSize) {
        return (false, null);
      }
    }
    return (true, ImExtModel(path: filePath));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkFileExist(message, fileSize: message.fileElem?.fileSize),
      builder: (BuildContext context, AsyncSnapshot<(bool, ImExtModel?)> snapshot) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: theme.themeColor, borderRadius: theme.borderRadius),
                padding: theme.padding,
                width: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListItem(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          getSuffix(),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      value: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(message.fileElem?.fileName ?? '',
                                    style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 40),
                              Text(
                                Utils.getFileSize(message.fileElem?.fileSize ?? 0),
                                style: TextStyle(fontSize: 10, color: theme.subtitleColor),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              snapshot.data?.$1 == true
                                  ? Wrap(
                                      spacing: 5,
                                      children: [
                                        ImButton(
                                          label: '打开',
                                          onPressed: () async {
                                            String? path = Utils.getValue(snapshot.data?.$2?.path, ext?.path);
                                            if (path != null) {
                                              Uri url = Uri.parse('file:$path');
                                              launchUrl(url);
                                            }
                                          },
                                        ),
                                        ImButton(
                                            label: '另存为',
                                            onPressed: () async {
                                              String? path = Utils.getValue(snapshot.data?.$2?.path, ext?.path);
                                              if (path != null) {
                                                String? dirPath = await FilePicker.platform.getDirectoryPath(dialogTitle: '另存为');
                                                if (dirPath != null) {
                                                  saveFile(path, dirPath, message.fileElem?.fileName ?? '');
                                                }
                                              }
                                            }),
                                        ImButton(label: '转发', onPressed: () {}),
                                        ImButton(
                                            label: '打开文件夹',
                                            onPressed: () {
                                              String? path = Utils.getValue(snapshot.data?.$2?.path, ext?.path);
                                              if (path != null) {
                                                int index = path.lastIndexOf('/');
                                                path = path.substring(0, index);
                                                final Uri url = Uri.parse('file:$path');
                                                launchUrl(url);
                                              }
                                            }),
                                      ],
                                    )
                                  : Wrap(
                                      spacing: 5,
                                      children: [
                                        ImButton(
                                          label: '下载',
                                          onPressed: ext == null
                                              ? () => onTapDownFile?.call(message)
                                              : ext!.isDownloading
                                                  ? null
                                                  : () => onTapDownFile?.call(message),
                                        ),
                                        ImButton(
                                          label: '另存为',
                                          onPressed: ext == null
                                              ? () {}
                                              : ext!.isDownloading
                                                  ? null
                                                  : () {},
                                        ),
                                        ImButton(label: '转发', onPressed: () {}),
                                      ],
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: snapshot.data?.$1 == true
                      ? 1
                      : ext == null
                          ? 0
                          : ext?.progress,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ],
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
