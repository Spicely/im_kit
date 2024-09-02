part of im_kit;

class ImFile extends ImBase {
  const ImFile({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onTap,
    super.onDoubleTap,
    super.contextMenuBuilder,
    super.showBackground,
  });

  @override
  Widget build(BuildContext context) {
    String? filename = msg.fileElem?.fileName;
    String? suffix = getSuffix();
    return getSelectableView(
      context,
      GestureDetector(
        onDoubleTap: () {
          onDoubleTap?.call(message);
        },
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Container(
                width: showBackground ? 220 : 160,
                height: showBackground ? 80 : 60,
                padding: const EdgeInsets.all(12),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: Text(
                                  ImCore.fixAutoLines(filename ?? ''),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            // 文件大小
                            Text(
                              ImCore.fixAutoLines(Utils.getFileSize(msg.fileElem?.fileSize ?? 0)),
                              style: const TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Stack(
                        children: [
                          const CachedImage(width: 40, height: 49, assetUrl: 'assets/icons/msg_default.png', package: 'im_kit'),
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: suffix == null
                                  ? const CachedImage(
                                      width: 20,
                                      height: 20,
                                      assetUrl: 'assets/icons/query.png',
                                      package: 'im_kit',
                                    )
                                  : Text(suffix, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          ),
                          if (ext.progress != null)
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(value: ext.progress),
                              ),
                            ),
                        ],
                      ),
                      if (showBackground) const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: ext.isDownloading ? ext.progress : 0,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 将字节数转化为MB
  String formatBytes(int bytes) {
    int kb = 1024;
    int mb = kb * 1024;
    int gb = mb * 1024;
    if (bytes >= gb) {
      return sprintf("%.1f GB", [bytes / gb]);
    } else if (bytes >= mb) {
      double f = bytes / mb;
      return sprintf(f > 100 ? "%.0f MB" : "%.1f MB", [f]);
    } else if (bytes > kb) {
      double f = bytes / kb;
      return sprintf(f > 100 ? "%.0f KB" : "%.1f KB", [f]);
    } else {
      return sprintf("%d B", [bytes]);
    }
  }

  /// 获取文件后缀名
  String? getSuffix() {
    final String? fileName = message.m.fileElem?.fileName;
    if (fileName == null) return '';
    final List<String> list = fileName.split('.');

    return Utils.getValue(list.last, null);
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
