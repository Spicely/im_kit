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

  /// 输入框样式
  final ImTextFieldTheme textFieldTheme;

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
    this.textFieldTheme = const ImTextFieldTheme(),
    this.backgroundColor = const Color(0xffffffff),
    this.textStyle = const TextStyle(fontSize: 14, color: Color(0xff333333)),
    this.atTextColor = const Color(0xff1a73e8),
    this.urlColor = const Color(0xff1a73e8),
    this.phoneColor = const Color(0xff1a73e8),
    this.emailColor = const Color(0xff1a73e8),
  });
}

class ImChatAppBarTheme {
  final Color? backgroundColor;

  final bool centerTitle;

  const ImChatAppBarTheme({
    this.backgroundColor = Colors.white,
    this.centerTitle = false,
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

  /// 间距
  final EdgeInsetsGeometry padding;

  ///引用间距
  final EdgeInsetsGeometry quotePadding;

  ///内容按钮的高度
  static const double ctxMenuH = 70;

  ///内容按钮的宽度
  static const double ctxMenuW = 50;

  ///内容按钮的icon高度
  static const double ctxMenuIconH = 30;

  ///内容按钮的icon宽度
  static const double ctxMenuIconW = 30;

  ///内容按钮的icon下方的间隔
  static const double ctxMenuGap = 6;

  ///内容按钮的文本样式
  static const TextStyle ctxMenuStyle = TextStyle(color: Colors.white, fontSize: 11);
  // const TextStyle(color:Colors.white, fontSize: 11),

  const ImMessageTheme({
    this.backgroundColor = const Color.fromRGBO(247, 247, 247, 1),
    this.meBackgroundColor = const Color.fromRGBO(255, 214, 0, 1),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.padding = const EdgeInsets.only(left: 6, right: 6, top: 8, bottom: 11),
    this.quotePadding = const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 6),
  });
}

class ImTextFieldTheme {
  final double height;

  /// 背景颜色
  final Color backgroundColor;

  final String hintText;

  /// 输入框颜色
  final Color textFieldColor;

  /// 输入框默认高度
  final double textFieldHeight;

  final BorderRadiusGeometry textFieldBorderRadius;

  const ImTextFieldTheme({
    this.backgroundColor = const Color.fromRGBO(241, 241, 241, 1),
    this.height = 58,
    this.hintText = '请输入消息...',
    this.textFieldColor = Colors.white,
    this.textFieldHeight = 38,
    this.textFieldBorderRadius = const BorderRadius.all(Radius.circular(6)),
  });
}
