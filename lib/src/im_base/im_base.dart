part of im_kit;
/*
 * Summary: 基础类
 * Created Date: 2023-07-13 21:11:28
 * Author: Spicely
 * -----
 * Last Modified: 2023-07-30 20:56:00
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class ImBase extends StatelessWidget {
  final bool isMe;

  final Message message;

  ImTheme get theme => ImCore.theme;

  const ImBase({
    super.key,
    required this.isMe,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class ImExtModel {
  final double? progress;

  final String? path;

  /// 语音播放
  bool isPlaying;

  /// 正在下载
  bool isDownloading;

  ImExtModel({
    this.progress,
    this.path,
    this.isPlaying = false,
    this.isDownloading = false,
  });
}

class ImCore {
  static final ImTheme theme = ImTheme();

  static final AudioPlayer _player = AudioPlayer();

  /// 文件路径
  static String dirPath = '';

  /// 文件保存文件夹
  static String get saveDir => join(dirPath, 'FileRecv', OpenIM.iMManager.uid);

  /// 检测文件是否存在
  static Future<(bool, ImExtModel?)> checkFileExist(Message msg, bool isMe, {int? fileSize}) async {
    String? locPath = msg.fileElem?.filePath ?? msg.videoElem?.videoPath ?? msg.soundElem?.soundPath;

    /// 本地文件
    if (locPath != null && isMe) {
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
    String? url = msg.fileElem?.sourceUrl ?? msg.videoElem?.videoUrl ?? msg.soundElem?.sourceUrl;
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

  /// 播放音频
  static Future<void> play(String url, String id) async {
    await _player.setFilePath(url);
    _player.play();
  }

  /// 暂停音频
  static Future<void> pause() async {
    await _player.pause();
  }
}

class ImTheme {
  /// 主题颜色
  final Color themeColor;

  /// 圆角
  final BorderRadiusGeometry borderRadius;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 副标题颜色
  final Color subtitleColor;

  ImTheme({
    this.themeColor = const Color(0xffffffff),
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.subtitleColor = const Color(0xff999999),
  });
}
