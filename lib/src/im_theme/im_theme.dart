part of im_kit;

class ImKitThemeData {
  /// 副标题颜色
  final Color subtitleColor;

  /// 对话框样式
  final ImChatTheme chatTheme;

  /// 多语言
  final ImLanguage language;

  const ImKitThemeData({
    this.subtitleColor = const Color(0xff999999),
    this.chatTheme = const ImChatTheme(),
    this.language = const ImLanguage(),
  });
}

class ImLanguage {
  /// 撤回
  final String revoke;

  /// 长按录制语音
  final String longPressRecordVoice;

  /// 松开立即发送 上滑取消
  final String releaseSendSlideCancel;

  /// 已下载
  final String downloaded;

  /// 未下载
  final String unDownload;

  /// 删除
  final String delete;

  /// 多选
  final String multiChoice;

  /// 转发
  final String forward;

  /// 回复
  final String reply;

  /// 复制
  final String copy;

  /// 聊天记录
  final String chatRecord;

  /// 图片
  final String picture;

  /// 视频
  final String video;

  /// 名片
  final String card;

  /// 语音
  final String voice;

  /// 表情
  final String emoji;

  /// 文件
  final String file;

  /// 位置
  final String location;

  /// 取消
  final String cancel;

  /// 下载
  final String download;

  /// 昨天
  final String yesterday;

  const ImLanguage({
    this.releaseSendSlideCancel = '松开立即发送 上滑取消',
    this.longPressRecordVoice = '长按录制语音',
    this.download = '下载',
    this.downloaded = '已下载',
    this.unDownload = '未下载',
    this.revoke = '撤回',
    this.delete = '删除',
    this.multiChoice = '多选',
    this.forward = '转发',
    this.reply = '回复',
    this.copy = '复制',
    this.chatRecord = '聊天记录',
    this.picture = '图片',
    this.video = '视频',
    this.card = '名片',
    this.voice = '语音',
    this.emoji = '表情',
    this.file = '文件',
    this.location = '位置',
    this.cancel = '取消',
    this.yesterday = '昨天',
  });
}

class _ImKitTheme extends InheritedTheme {
  const _ImKitTheme({
    required this.data,
    required super.child,
  });

  final ImKitThemeData data;

  @override
  bool updateShouldNotify(covariant _ImKitTheme oldWidget) => oldWidget.data != data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return _ImKitTheme(data: data, child: child);
  }
}

class ImKitTheme extends StatelessWidget {
  const ImKitTheme({
    super.key,
    required this.data,
    required this.child,
  });

  final ImKitThemeData data;

  final Widget child;

  static ImKitThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ImKitTheme>()!.data;
  }

  static ImKitThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ImKitTheme>()?.data;
  }

  @override
  Widget build(BuildContext context) {
    return _ImKitTheme(data: data, child: child);
  }
}
