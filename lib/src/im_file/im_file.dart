part of im_kit;

class ImFile extends ImBase {
  final void Function(MessageExt message)? onTapDownFile;

  const ImFile({
    Key? key,
    required bool isMe,
    required MessageExt message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  ImExtModel get ext => message.ext;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: theme.borderRadius),
            padding: theme.padding,
            width: 240,
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.redAccent),
                    child: Text(
                      getSuffix(),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  value: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.m.fileElem?.fileName ?? '',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${Utils.getFileSize(message.m.fileElem?.fileSize ?? 0)} / ${ext.path == null ? '未下载' : '已下载'}',
                            style: TextStyle(fontSize: 10, color: theme.subtitleColor),
                          )
                          // snapshot.data?.$1 == true
                          //     ? Wrap(
                          //         spacing: 5,
                          //         children: [
                          //           ImButton(
                          //             label: '打开',
                          //             onPressed: () async {
                          //               String? path = Utils.getValue(snapshot.data?.$2?.path, ext.path);
                          //               if (path != null) {
                          //                 Uri url = Uri.parse('file:$path');
                          //                 launchUrl(url);
                          //               }
                          //             },
                          //           ),
                          //           ImButton(
                          //               label: '另存为',
                          //               onPressed: () async {
                          //                 String? path = Utils.getValue(snapshot.data?.$2?.path, ext.path);
                          //                 if (path != null) {
                          //                   String? dirPath = await FilePicker.platform.getDirectoryPath(dialogTitle: '另存为');
                          //                   if (dirPath != null) {
                          //                     saveFile(path, dirPath, message.fileElem?.fileName ?? '');
                          //                   }
                          //                 }
                          //               }),
                          //           ImButton(label: '转发', onPressed: () {}),
                          //           ImButton(
                          //               label: '打开文件夹',
                          //               onPressed: () {
                          //                 String? path = Utils.getValue(snapshot.data?.$2?.path, ext.path);
                          //                 if (path != null) {
                          //                   int index = path.lastIndexOf('/');
                          //                   path = path.substring(0, index);
                          //                   final Uri url = Uri.parse('file:$path');
                          //                   launchUrl(url);
                          //                 }
                          //               }),
                          //         ],
                          //       )
                          //     : Wrap(
                          //         spacing: 5,
                          //         children: [
                          //           // ImButton(
                          //           //   label: '下载',
                          //           //   onPressed: ext == null
                          //           //       ? () => onTapDownFile?.call(message)
                          //           //       : ext.isDownloading
                          //           //           ? null
                          //           //           : () => onTapDownFile?.call(message),
                          //           // ),
                          //           // ImButton(
                          //           //   label: '另存为',
                          //           //   onPressed: ext == null
                          //           //       ? () {}
                          //           //       : ext!.isDownloading
                          //           //           ? null
                          //           //           : () {},
                          //           // ),
                          //           ImButton(label: '转发', onPressed: () {}),
                          //         ],
                          //       ),
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
              value: ext.isDownloading ? ext.progress : 0,
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
        ],
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
