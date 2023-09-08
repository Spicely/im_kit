part of im_kit;
/*
 * Summary: 基础类
 * Created Date: 2023-07-13 21:11:28
 * Author: Spicely
 * -----
 * Last Modified: 2023-09-08 10:39:59
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

  final MessageExt message;

  ImTheme get theme => ImCore.theme;

  ImExtModel get ext => message.ext;

  Message get msg => message.m;

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

class MessageExt {
  final ImExtModel ext;

  Message m;

  MessageExt({
    required this.ext,
    required this.m,
  });
}

extension ExtensionMessage on Message {
  MessageExt toExt() {
    final ext = ImExtModel();
    switch (contentType) {
      case MessageType.voice:
      case MessageType.video:
      case MessageType.file:

        /// 优先判断本地文件
        String? filePath = pictureElem?.sourcePath ?? soundElem?.soundPath ?? videoElem?.videoPath ?? fileElem?.filePath;
        if (filePath != null && File(filePath).existsSync()) {
          ext.path = filePath;
          break;
        }
        filePath = ImCore.getSavePath(this);
        if (File(filePath).existsSync()) {
          ext.path = filePath;
        }
        break;
      default:
    }

    return MessageExt(
      ext: ext,
      m: this,
    );
  }
}

class ImExtModel {
  double? progress;

  String? path;

  /// 语音播放
  bool isPlaying;

  /// 正在下载
  bool isDownloading;

  /// 预览图
  Uint8List? preview;

  /// 预览地址
  String? previewPath;

  ImExtModel({
    this.progress,
    this.path,
    this.isPlaying = false,
    this.isDownloading = false,
    this.preview,
    this.previewPath,
  });
}

class ImCore {
  static final ImTheme theme = ImTheme();

  static final AudioPlayer _player = AudioPlayer();

  /// 文件路径
  static String dirPath = '';

  static String _playID = '';

  /// 文件保存文件夹
  static String get saveDir => join(dirPath, 'FileRecv', OpenIM.iMManager.uid);

  /// 播放回调
  static void onPlayerStateChanged(void Function(PlayerState state, String id) listener) {
    _player.onPlayerStateChanged.listen((PlayerState state) => listener(state, _playID));
  }

  /// 文件保存地址
  static String getSavePath(Message msg) {
    String? url = msg.fileElem?.sourceUrl ?? msg.videoElem?.videoUrl ?? msg.soundElem?.sourceUrl ?? msg.pictureElem?.sourcePicture?.url;
    if (url == null) return '';
    String fileName = url.split('/').last;
    return join(saveDir, fileName);
  }

  /// 文件保存地址
  static String getSavePathForFilePath(String path) {
    String fileName = path.split('/').last;
    return join(saveDir, fileName);
  }

  /// 检测文件是否存在
  static Future<(bool, ImExtModel?)> checkFileExist(Message msg, bool isMe, {int? fileSize}) async {
    String? locPath = msg.fileElem?.filePath ?? msg.videoElem?.videoPath ?? msg.soundElem?.soundPath;

    /// 本地文件
    if (locPath != null && isMe) {
      File file = File(locPath);
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
  static Future<void> play(String url, String id, {void Function(String)? onPlayerBeforePlay}) async {
    onPlayerBeforePlay?.call(_playID);
    await _player.play(DeviceFileSource(url));
    _playID = id;
  }

  /// 暂停音频
  static Future<void> stop() async {
    await _player.stop();
  }

  /// 跳转到图片预览页面
  static void pushPreview(
    BuildContext context,
    List<MessageExt> messages,
    MessageExt currentMessage, {
    void Function()? onSaveSuccess,
    void Function()? onSaveFailure,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImPreview(
          messages: messages,
          currentMessage: currentMessage,
          onSaveSuccess: onSaveSuccess,
          onSaveFailure: onSaveFailure,
        ),
      ),
    );
  }

  /// 跳转到视屏播放页面
  static void pushVideoPlayer(
    BuildContext context,
    MessageExt message, {
    void Function()? onSaveSuccess,
    void Function()? onSaveFailure,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImPlayer(
          message: message,
          onSaveSuccess: onSaveSuccess,
          onSaveFailure: onSaveFailure,
        ),
      ),
    );
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

mixin ImKitListen {
  /// 下载进度
  void onDownloadProgress(String id, double progress);

  /// 下载成功
  void onDownloadSuccess(String id, List<String> paths);

  /// 下载失败
  void onDownloadFailure(String id, String error);
}
