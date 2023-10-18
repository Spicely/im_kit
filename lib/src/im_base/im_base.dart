part of im_kit;
/*
 * Summary: 基础类
 * Created Date: 2023-07-13 21:11:28
 * Author: Spicely
 * -----
 * Last Modified: 2023-09-11 09:38:52
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

  /// 网址点击事件
  final void Function(String)? onUrlTap;

  /// 邮箱点击事件
  final void Function(String)? onEmailTap;

  /// 电话点击事件
  final void Function(String)? onPhoneTap;

  /// 点击下载文件
  final void Function(MessageExt message)? onTapDownFile;

  /// 点击播放视频
  final void Function(MessageExt message)? onTapPlayVideo;

  const ImBase({
    super.key,
    required this.isMe,
    required this.message,
    this.onClickMenu,
    this.onUrlTap,
    this.onEmailTap,
    this.onPhoneTap,
    this.onTapDownFile,
    this.onTapPlayVideo,
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

  Map<String, Object?> toJson() {
    return {
      'ext': ext.toJson(),
      'm': m.toJson(),
    };
  }

  factory MessageExt.fromJson(Map<String, dynamic> json) {
    return MessageExt(
      ext: ImExtModel(
        progress: json['ext']?['progress'] as double?,
        path: json['ext']?['path'] as String?,
        isPlaying: json['ext']?['isPlaying'] as bool? ?? false,
        isDownloading: json['ext']?['isDownloading'] as bool? ?? false,
        canDelete: json['ext']?['canDelete'] as bool? ?? true,
        createTime: DateTime.fromMillisecondsSinceEpoch(json['ext']?['createTime'] as int? ?? 0),
        preview: json['ext']?['preview'] as Uint8List?,
        previewPath: json['ext']?['previewPath'] as String?,
        secretKey: json['ext']?['secretKey'] as String? ?? '',
      ),
      m: Message.fromJson(json['m'] as Map<String, Object?>? ?? {}),
    );
  }
}

String _getSecretKey(Message message, String currentSecretKey) {
  String? k = message.ex ?? message.quoteElem?.quoteMessage?.ex ?? message.atElem?.quoteMessage?.ex;
  return k ?? currentSecretKey;
}

String _getAtText(Message msg) {
  String v = msg.atElem?.text ?? '';
  List<AtUserInfo> atUsersInfo = msg.atElem?.atUsersInfo ?? [];
  // /// 匹配艾特用户
  String atReg = atUsersInfo.map((v) => '@${v.atUserID} ').join('|');

  String regExp;
  if (atUsersInfo.isEmpty) {
    return v;
  } else {
    regExp = [atReg].join('|');
  }
  return v.splitMapJoin(
    RegExp('($regExp)'),
    onMatch: (Match m) {
      String value = m.group(0)!;
      if (RegExp(atReg).hasMatch(value)) {
        String id = value.replaceAll('@', '').trim();
        AtUserInfo? atUserInfo = atUsersInfo.firstWhereOrNull((v) => v.atUserID == id);
        if (atUserInfo == null) {
          return value;
        } else {
          if (atUserInfo.atUserID == OpenIM.iMManager.uid) {
            return '@你 ';
          } else {
            return '@${atUserInfo.groupNickname} ';
          }
        }
      }
      return '';
    },
    onNonMatch: (String n) {
      return n;
    },
  );
}

class ImExtModel {
  /// 创建时间
  final DateTime createTime;

  double? progress;

  String? path;

  /// 语音播放
  bool isPlaying;

  /// 正在下载
  bool isDownloading;

  /// 是否可以删除
  bool canDelete;

  /// 预览图
  Uint8List? preview;

  /// 预览地址
  String? previewPath;

  /// 密钥
  String secretKey;

  /// 宽
  double? width;

  /// 高
  double? height;

  /// 自定义数据
  Map<String, dynamic>? data;

  ImExtModel({
    this.progress,
    this.path,
    this.isPlaying = false,
    this.isDownloading = false,
    this.canDelete = true,
    required this.createTime,
    this.preview,
    this.previewPath,
    this.secretKey = '',
    this.width,
    this.height,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'progress': progress,
      'path': path,
      'isPlaying': isPlaying,
      'isDownloading': isDownloading,
      'canDelete': canDelete,
      'createTime': createTime.millisecondsSinceEpoch,
      'preview': preview,
      'previewPath': previewPath,
      'secretKey': secretKey,
    };
  }
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
      return (true, ImExtModel(path: msg.fileElem!.filePath!, createTime: DateTime.now()));
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
    return (true, ImExtModel(path: filePath, createTime: DateTime.now()));
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
    Future<void> Function(String)? onSaveBefore,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImPreview(
          messages: messages,
          currentMessage: currentMessage,
          onSaveSuccess: onSaveSuccess,
          onSaveFailure: onSaveFailure,
          onSaveBefore: onSaveBefore,
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
  final ImChatTheme chatTheme;

  /// 多语言
  final ImLanguage language;

  const ImTheme({
    this.subtitleColor = const Color(0xff999999),
    this.avatarTheme = const ImAvatarTheme(),
    this.chatTheme = const ImChatTheme(),
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

(double width, double height) _computedSize({double? width, double? height}) {
  double w = width?.toDouble() ?? 1.0;
  double h = height?.toDouble() ?? 1.0;
  if (w == 0) w = 120;
  if (h == 0) h = 120;

  // 获取宽高比例
  double ratio = w / h;
  double maxWidth = 180;
  // 最小高度
  double minHeight = 30;

  if (w > maxWidth) {
    w = maxWidth;
    h = w / ratio;
  }

  if (h < minHeight) {
    h = minHeight;
    w = h * ratio;
  }
  return (w, h);
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

class ImChatTheme {
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

  /// @字体颜色
  final Color? atTextColor;

  /// 网址颜色
  final Color? urlColor;

  /// 电话颜色
  final Color? phoneColor;

  /// 邮箱颜色
  final Color? emailColor;

  const ImChatTheme({
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.backgroundColor = const Color(0xffffffff),
    this.meBackgroundColor,
    this.textStyle = const TextStyle(fontSize: 14, color: Color(0xff333333)),
    this.atTextColor = const Color(0xff1a73e8),
    this.urlColor = const Color(0xff1a73e8),
    this.phoneColor = const Color(0xff1a73e8),
    this.emailColor = const Color(0xff1a73e8),
  });
}

String _fixAutoLines(String data) {
  return Characters(data).join('\u{200B}');
}

mixin ImKitListen {
  /// 下载进度
  void onDownloadProgress(String id, double progress);

  /// 下载成功
  void onDownloadSuccess(String id, List<String> paths);

  /// 下载失败
  void onDownloadFailure(String id, String error);
}
