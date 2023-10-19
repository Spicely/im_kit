part of im_kit;

class ImChatTheme {
  /// 背景颜色
  final Color backgroundColor;

  /// 头像样式
  final ImAvatarTheme avatarTheme;

  /// appBar
  final ImChatAppBarTheme appBarTheme;

  /// 消息框样式
  final ImMessageTheme messageTheme;

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
    this.appBarTheme = const ImChatAppBarTheme(),
    this.avatarTheme = const ImAvatarTheme(),
    this.messageTheme = const ImMessageTheme(),
    this.backgroundColor = const Color(0xffffffff),
    this.textStyle = const TextStyle(fontSize: 14, color: Color(0xff333333)),
    this.atTextColor = const Color(0xff1a73e8),
    this.urlColor = const Color(0xff1a73e8),
    this.phoneColor = const Color(0xff1a73e8),
    this.emailColor = const Color(0xff1a73e8),
  });
}

class ImChatAppBarTheme {
  final Color backgroundColor;

  final bool centerTitle;

  final TextStyle style;

  final IconThemeData iconTheme;

  const ImChatAppBarTheme({
    this.backgroundColor = Colors.white,
    this.centerTitle = true,
    this.style = const TextStyle(fontSize: 16, color: Colors.black),
    this.iconTheme = const IconThemeData(color: Colors.black),
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
    this.circular = 40,
    this.fit = BoxFit.cover,
  });
}

class ImMessageTheme {
  /// 背景颜色
  final Color backgroundColor;

  /// 自己的背景颜色
  final Color meBackgroundColor;

  /// 圆角
  final BorderRadiusGeometry borderRadius;

  final TextStyle? style;

  /// 间距
  final EdgeInsetsGeometry padding;

  const ImMessageTheme({
    this.backgroundColor = const Color.fromRGBO(247, 247, 247, 1),
    this.meBackgroundColor = const Color.fromRGBO(255, 214, 0, 1),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    this.style,
  });
}
