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

  /// 是否显示选择按钮
  final bool showSelect;

  final bool showBackground;

  final void Function(MenuItemProvider, MessageExt)? onClickMenu;

  ImExtModel get ext => message.ext;

  Message get msg => message.m;

  // 点击消息体
  final void Function(MessageExt message)? onTap;

  /// 网址点击事件
  final void Function(String)? onTapUrl;

  /// 邮箱点击事件
  final void Function(String)? onTapEmail;

  /// 电话点击事件
  final void Function(String)? onTapPhone;

  /// 点击下载文件
  final void Function(MessageExt message)? onTapDownFile;

  /// 点击播放视频
  final void Function(MessageExt message)? onTapPlayVideo;

  /// 引用消息点击
  final void Function(MessageExt message)? onQuoteMessageTap;

  // 双击点击消息体
  final void Function(MessageExt message)? onDoubleTap;

  /// 位置信息点击
  final void Function(MessageExt message)? onLocationTap;

  final Widget Function(BuildContext, MessageExt, EditableTextState)? contextMenuBuilder;

  Widget getSelectableView(BuildContext context, Widget child) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    // return Container(
    //   constraints: BoxConstraints(maxWidth: showSelect ? 470 : 500),
    //   decoration: BoxDecoration(
    //     color: ImCore.noBgMsgType.contains(message.m.contentType)
    //         ? null
    //         : isMe
    //             ? chatTheme.messageTheme.meBackgroundColor
    //             : chatTheme.messageTheme.backgroundColor,
    //     borderRadius: chatTheme.messageTheme.borderRadius,
    //   ),
    //   padding: ImCore.noPadMsgType.contains(message.m.contentType) ? null : chatTheme.messageTheme.padding,
    //   child: child,
    // );
    return Container(
      constraints: BoxConstraints(maxWidth: showSelect ? 470 : 500),
      child: SelectableText.rich(
        onTap: () {
          switch (message.m.contentType) {
            case MessageType.location:
              onLocationTap?.call(message);
              break;
            default:
              onTap?.call(message);
          }
        },
        TextSpan(
          children: [
            WidgetSpan(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    color: showBackground
                        ? ImCore.noBgMsgType.contains(msg.contentType)
                            ? null
                            : isMe
                                ? chatTheme.messageTheme.meBackgroundColor
                                : chatTheme.messageTheme.backgroundColor
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: chatTheme.messageTheme.borderRadius,
                  ),
                  padding: showBackground
                      ? ImCore.noPadMsgType.contains(msg.contentType)
                          ? null
                          : chatTheme.messageTheme.padding
                      : null,
                  child: child,
                ),
              ),
            ),
          ],
        ),
        style: chatTheme.textStyle,
        contextMenuBuilder: (BuildContext context, EditableTextState state) {
          if (contextMenuBuilder == null) {
            return AdaptiveTextSelectionToolbar.editableText(
              editableTextState: state,
            );
          } else {
            return contextMenuBuilder!(context, message, state);
          }
        },
      ),
    );
  }

  const ImBase({
    super.key,
    required this.isMe,
    required this.message,
    required this.showSelect,
    this.onClickMenu,
    this.onTap,
    this.onTapUrl,
    this.onTapEmail,
    this.onTapPhone,
    this.onTapDownFile,
    this.onTapPlayVideo,
    this.onQuoteMessageTap,
    this.contextMenuBuilder,
    this.onDoubleTap,
    this.showBackground = true,
    this.onLocationTap,
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
        key: GlobalKey(),
        progress: json['ext']?['progress'] as double?,
        file: json['ext']?['path'] != null ? File(json['ext']?['path']) : null,
        isPlaying: json['ext']?['isPlaying'] as bool? ?? false,
        isDownloading: json['ext']?['isDownloading'] as bool? ?? false,
        canDelete: json['ext']?['canDelete'] as bool? ?? true,
        createTime: DateTime.fromMillisecondsSinceEpoch(json['ext']?['createTime'] as int? ?? 0),
        previewFile: json['ext']?['previewFile'] as File?,
        secretKey: json['ext']?['secretKey'] as String? ?? '',
      ),
      m: Message.fromJson(json['m'] as Map<String, Object?>? ?? {}),
    );
  }
}

abstract class ImExtErrorCode {
  /// 下载失败
  static const int downloadFailure = 1;
}

class ImExtModel {
  /// 创建时间
  final DateTime createTime;

  final GlobalKey key;

  double? progress;

  File? file;

  /// 语音播放
  bool isPlaying;

  /// 正在下载
  bool isDownloading;

  /// 是否可以删除
  bool canDelete;

  /// 预览地址
  File? previewFile;

  /// 密钥
  String secretKey;

  /// 宽
  double? width;

  /// 高
  double? height;

  /// 自定义数据
  dynamic data;

  /// 引用数据
  MessageExt? quoteMessage;

  /// 是否为语音消息
  bool isVoice;

  /// 是否为阅后即焚消息
  bool isPrivateChat;

  /// 是否为红包消息
  bool isRedEnvelope;

  /// 是否开启阅后即焚
  bool isSnapchat;

  /// 双向清除消息
  bool isBothDelete;

  /// 计时器
  Timer? timer;

  /// 倒计时
  int seconds;

  bool showTime;

  /// 发送时间
  String time;

  /// 错误码
  int? errorCode;

  ImExtModel({
    this.progress,
    this.file,
    this.isVoice = false,
    this.isPlaying = false,
    this.isDownloading = false,
    this.canDelete = true,
    required this.createTime,
    required this.key,
    this.previewFile,
    this.secretKey = '',
    this.width,
    this.height,
    this.data,
    this.quoteMessage,
    this.isPrivateChat = false,
    this.isRedEnvelope = false,
    this.isSnapchat = false,
    this.isBothDelete = false,
    this.timer,
    this.seconds = 30,
    this.showTime = false,
    this.time = '',
    this.errorCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'progress': progress,
      'path': file?.path,
      'isPlaying': isPlaying,
      'isDownloading': isDownloading,
      'canDelete': canDelete,
      'createTime': createTime.millisecondsSinceEpoch,
      'previewPath': previewFile?.path,
      'secretKey': secretKey,
      'width': width,
      'height': height,
      'data': data,
      'quoteMessage': quoteMessage?.toJson(),
      'isVoice': isVoice,
      'isPrivateChat': isPrivateChat,
      'isRedEnvelope': isRedEnvelope,
      'isSnapchat': isSnapchat,
      'isBothDelete': isBothDelete,
      'seconds': seconds,
      'showTime': showTime,
      'time': time,
      'errorCode': errorCode,
    };
  }
}

class ImCore {
  static final a.AudioPlayer _player = a.AudioPlayer();

  /// 文件路径
  static String dirPath = '';

  static String _playID = '';

  /// 临时缓存文件夹
  static String get tempPath => join(dirPath, 'Temp');

  static init(String path) {
    dirPath = path;
    Directory(tempPath).createSync(recursive: true);
  }

  /// 播放回调
  static void onPlayerStateChanged(void Function(a.PlayerState state, String id) listener) {
    _player.onPlayerStateChanged.listen((a.PlayerState state) => listener(state, _playID));
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
      return (true, ImExtModel(key: GlobalKey(), file: File(msg.fileElem!.filePath!), createTime: DateTime.now()));
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
    return (true, ImExtModel(key: GlobalKey(), file: File(filePath), createTime: DateTime.now()));
  }

  /// 播放音频
  static Future<void> play(String id, String url, {void Function(String)? onPlayerBeforePlay}) async {
    onPlayerBeforePlay?.call(_playID);
    _playID = id;
    await _player.play(a.DeviceFileSource(url));
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

  /// 没有内边距
  static List<int> noPadMsgType = [MessageType.picture, MessageType.file, MessageType.card, MessageType.video, MessageType.location, MessageType.merger, 300];

  /// 内显示
  static List<int> padType = [MessageType.picture, MessageType.card, MessageType.video, MessageType.location];

  /// 没有背景颜色的消息
  static List<int> noBgMsgType = [300, MessageType.picture, MessageType.video];

  static String fixAutoLines(String data) {
    return Characters(data).join('\u{200B}');
  }

  /// 需要被忽略的消息
  static final List<int> types = [
    110,
    111,
    1000,
    1501,
    1502,
    1503,
    1504,
    1505,
    1506,
    1507,
    1508,
    1509,
    1510,
    1511,
    1514,
    1515,
    1201,
    1202,
    1203,
    1204,
    1205,
    27,
    77,
    1701,
    1512,
    1513,
    2023,
    2024,
    2025,
  ];

  static const Map<String, String> emojiFaces = <String, String>{
    '[00]': 'ic_face_10000',
    '[01]': 'ic_face_10001',
    '[02]': 'ic_face_10002',
    '[03]': 'ic_face_10003',
    '[04]': 'ic_face_10004',
    '[05]': 'ic_face_10005',
    '[06]': 'ic_face_10006',
    '[07]': 'ic_face_10007',
    '[08]': 'ic_face_10008',
    '[09]': 'ic_face_10009',
    '[10]': 'ic_face_10010',
    '[11]': 'ic_face_10011',
    '[12]': 'ic_face_10012',
    '[13]': 'ic_face_10013',
    '[14]': 'ic_face_10014',
    '[15]': 'ic_face_10015',
    '[16]': 'ic_face_10016',
    '[17]': 'ic_face_10017',
    '[18]': 'ic_face_10018',
    '[19]': 'ic_face_10019',
    '[20]': 'ic_face_10020',
    '[21]': 'ic_face_10021',
    '[22]': 'ic_face_10022',
    '[23]': 'ic_face_10023',
    '[24]': 'ic_face_10024',
    '[25]': 'ic_face_10025',
    '[26]': 'ic_face_10026',
    '[27]': 'ic_face_10027',
    '[28]': 'ic_face_10028',
    '[29]': 'ic_face_10029',
    '[30]': 'ic_face_10030',
    '[31]': 'ic_face_10031',
    '[32]': 'ic_face_10032',
    '[33]': 'ic_face_10033',
    '[34]': 'ic_face_10034',
    '[35]': 'ic_face_10035',
    '[36]': 'ic_face_10036',
    '[37]': 'ic_face_10037',
    '[38]': 'ic_face_10038',
    '[39]': 'ic_face_10039',
    '[40]': 'ic_face_10040',
    '[41]': 'ic_face_10041',
    '[42]': 'ic_face_10042',
    '[43]': 'ic_face_10043',
    '[44]': 'ic_face_10044',
    '[45]': 'ic_face_10045',
    '[46]': 'ic_face_10046',
    '[47]': 'ic_face_10047',
    '[48]': 'ic_face_10048',
    '[49]': 'ic_face_10049',
    '[50]': 'ic_face_10050',
    '[51]': 'ic_face_10051',
    '[52]': 'ic_face_10052',
    '[53]': 'ic_face_10053',
    '[54]': 'ic_face_10054',
    '[55]': 'ic_face_10055',
    '[56]': 'ic_face_10056',
    '[57]': 'ic_face_10057',
    '[58]': 'ic_face_10058',
    '[59]': 'ic_face_10059',
    '[60]': 'ic_face_10060',
    '[61]': 'ic_face_10061',
    '[62]': 'ic_face_10062',
    '[63]': 'ic_face_10063',
    '[64]': 'ic_face_10064',
    '[65]': 'ic_face_10065',
    '[66]': 'ic_face_10066',
    '[67]': 'ic_face_10067',
    '[68]': 'ic_face_10068',
    '[69]': 'ic_face_10069',
    '[70]': 'ic_face_10070',
    '[71]': 'ic_face_10071',
    '[72]': 'ic_face_10072',
    '[73]': 'ic_face_10073',
    '[74]': 'ic_face_10074',
    '[75]': 'ic_face_10075',
    '[76]': 'ic_face_10076',
    '[77]': 'ic_face_10077',
    '[78]': 'ic_face_10078',
    '[79]': 'ic_face_10079',
    '[80]': 'ic_face_10080',
    '[81]': 'ic_face_10081',
    '[82]': 'ic_face_10082',
    '[83]': 'ic_face_10083',
    '[85]': 'ic_face_10085',
    '[86]': 'ic_face_10086',
    '[87]': 'ic_face_10087',
    '[88]': 'ic_face_10088',
    '[89]': 'ic_face_10089',
    '[90]': 'ic_face_10090',
    '[91]': 'ic_face_10091',
    '[92]': 'ic_face_10092',
    '[93]': 'ic_face_10093',
    '[94]': 'ic_face_10094',
    '[95]': 'ic_face_10095',
    '[96]': 'ic_face_10096',
    '[97]': 'ic_face_10097',
    '[98]': 'ic_face_10098',
    '[99]': 'ic_face_10099',
    '[100]': 'ic_face_10100',
  };
}

(double width, double height) _computedSize({double? width, double? height}) {
  double w = width?.toDouble() ?? 1.0;
  double h = height?.toDouble() ?? 1.0;
  if (w == 0) w = 120;
  if (h == 0) h = 120;

  // 获取宽高比例
  double ratio = w / h;
  double maxWidth = 140;
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

mixin ImKitListen {
  /// 下载进度
  void onDownloadProgress(String id, double progress) {}

  /// 下载成功
  void onDownloadSuccess(String id, List<String> paths) {}

  /// 下载失败
  void onDownloadFailure(String id, String error) {}
}

class SignalingType {
  /// 邀请通知
  static const int CustomSignalingInviteType = 10;

  /// 同意通话
  static const int CustomSignalingAcceptType = 11;

  /// 拒绝通话
  static const int CustomSignalingRejectType = 12;

  /// 取消通话
  static const int CustomSignalingCancelType = 13;

  /// 挂断通话
  static const int CustomSignalingHungUpType = 14;

  /// 邀请超时
  static const int CustomSignalingTimeoutType = 15;

  /// 正在通话中
  static const int CustomSignalingIsBusyType = 16;

  /// 持续呼叫
  static const int CustomSignalingCallType = 20;

  /// 等待重连
  static const int CustomSignalingAwaitType = 21;

  ///是否能继续通话
  static bool isCanDeal(int type) {
    switch (type) {
      case SignalingType.CustomSignalingRejectType:
        return true;
      case SignalingType.CustomSignalingCancelType:
        return true;
      case SignalingType.CustomSignalingHungUpType:
        return true;
      case SignalingType.CustomSignalingTimeoutType:
        return true;
      default:
        return false;
    }
  }

  ///解析信令消息
  static Map parseCallMessage(Message msg) {
    if (msg.contentType != MessageType.custom) {
      return {"err": true};
    }
    try {
      var data = jsonDecode(msg.content!);
      data = jsonDecode(data["data"]);
      return {"contentType": data["contentType"], "signaling_id": data["signaling_id"], "channelName": data["channelName"], "call_duration": data["call_duration"], "signaling_call_seq": data["signaling_call_seq"], "err": false};
    } catch (e) {
      return {"err": true};
    }
  }
}

enum MenuItemType {
  /// 复制
  copy,

  /// 删除
  delete,

  /// 转发
  forward,

  /// 引用
  quote,

  /// 收藏
  collect,

  /// 多选
  multiSelect,

  /// 撤回
  recall,
}

class ItemModel {
  String title;

  Widget icon;

  MenuItemType type;

  ItemModel(this.title, this.icon, this.type);
}
