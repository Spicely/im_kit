part of im_kit;

class ImConversationTheme {
  /// 标题
  final TextStyle titleStyle;

  /// 副标题
  final TextStyle subtitleStyle;

  const ImConversationTheme({
    this.titleStyle = const TextStyle(fontSize: 14),
    this.subtitleStyle = const TextStyle(fontSize: 12, color: Color.fromRGBO(179, 179, 179, 1)),
  });
}
