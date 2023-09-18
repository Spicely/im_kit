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

  final void Function(MenuItemProvider, MessageExt)? onClickMenu;

  ImTheme get theme => ImCore.theme;

  ImExtModel get ext => message.ext;

  Message get msg => message.m;

  const ImBase({
    super.key,
    required this.isMe,
    required this.message,
    this.onClickMenu,
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
    final ext = ImExtModel(itemKey: GlobalKey());
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
  final GlobalKey itemKey;

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
    required this.itemKey,
    this.progress,
    this.path,
    this.isPlaying = false,
    this.isDownloading = false,
    this.preview,
    this.previewPath,
  });
}

class ImCore {
  static ImTheme theme = const ImTheme();

  static final a.AudioPlayer _player = a.AudioPlayer();

  /// 文件路径
  static String dirPath = '';

  static String _playID = '';

  /// 文件保存文件夹
  static String get saveDir => join(dirPath, 'FileRecv', OpenIM.iMManager.uid);

  /// 播放回调
  static void onPlayerStateChanged(void Function(a.PlayerState state, String id) listener) {
    _player.onPlayerStateChanged.listen((a.PlayerState state) => listener(state, _playID));
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
      return (true, ImExtModel(itemKey: GlobalKey(), path: msg.fileElem!.filePath!));
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
    return (true, ImExtModel(itemKey: GlobalKey(), path: filePath));
  }

  /// 播放音频
  static Future<void> play(String url, String id, {void Function(String)? onPlayerBeforePlay}) async {
    onPlayerBeforePlay?.call(_playID);
    await _player.play(a.DeviceFileSource(url));
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
  /// 副标题颜色
  final Color subtitleColor;

  /// 头像样式
  final ImAvatarTheme avatarTheme;

  /// 对话框样式
  final ImDialogTheme dialogTheme;

  /// 多语言
  final ImLanguage language;

  const ImTheme({
    this.subtitleColor = const Color(0xff999999),
    this.avatarTheme = const ImAvatarTheme(),
    this.dialogTheme = const ImDialogTheme(),
    this.language = const ImLanguage(),
  });
}

class ImLanguage {
  /// 长按录制语音
  final String longPressRecordVoice;

  /// 松开立即发送 上滑取消
  final String releaseSendSlideCancel;

  /// 已下载
  final String downloaded;

  /// 未下载
  final String unDownload;

  const ImLanguage({
    this.releaseSendSlideCancel = '松开立即发送 上滑取消',
    this.longPressRecordVoice = '长按录制语音',
    this.downloaded = '已下载',
    this.unDownload = '未下载',
  });
}

class ImAvatarTheme {
  /// 宽度
  final double width;

  /// 高度
  final double height;

  /// 圆角
  final double circular;

  /// 图片填充模式
  final BoxFit fit;

  const ImAvatarTheme({
    this.width = 40,
    this.height = 40,
    this.circular = 5,
    this.fit = BoxFit.cover,
  });
}

class ImDialogTheme {
  /// 间距
  final EdgeInsetsGeometry padding;

  /// 圆角
  final BorderRadiusGeometry borderRadius;

  /// 背景颜色
  final Color backgroundColor;

  /// 我的消息颜色
  final Color? meBackgroundColor;

  /// 文本样式
  final TextStyle textStyle;

  const ImDialogTheme({
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.backgroundColor = const Color(0xffffffff),
    this.meBackgroundColor,
    this.textStyle = const TextStyle(fontSize: 16, color: Color(0xff333333)),
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
