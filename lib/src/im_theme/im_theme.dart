part of im_kit;

class ImKitThemeData {
  /// 副标题颜色
  final Color subtitleColor;

  /// 对话框样式
  final ImChatTheme chatTheme;

  // /// 多语言
  // final ImLanguage language;

  const ImKitThemeData({
    this.subtitleColor = const Color(0xff999999),
    this.chatTheme = const ImChatTheme(),
    // this.language = const ImLanguage(),
  });
}

// class ImLanguage {
//   /// 长按录制语音
//   final String longPressRecordVoice;

//   /// 松开立即发送 上滑取消
//   final String releaseSendSlideCancel;

//   /// 已下载
//   final String downloaded;

//   /// 未下载
//   final String unDownload;

//   const ImLanguage({
//     this.releaseSendSlideCancel = '松开立即发送 上滑取消',
//     this.longPressRecordVoice = '长按录制语音',
//     this.downloaded = '已下载',
//     this.unDownload = '未下载',
//   });
// }

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
