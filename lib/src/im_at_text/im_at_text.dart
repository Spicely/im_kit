part of im_kit;

class ImAtText extends ImBase {
  final List<MenuItemProvider>? textMenuItems;

  const ImAtText({
    super.key,
    required super.isMe,
    required super.message,
    super.onClickMenu,
    this.textMenuItems,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: textMenuItems == null
          ? null
          : () {
              onShow(context);
            },
      child: Container(
        key: message.ext.itemKey,
        decoration: BoxDecoration(color: theme.themeColor, borderRadius: theme.borderRadius),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: theme.padding,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(message.m.content ?? ''),
        ),
      ),
    );
  }

  void onShow(BuildContext context) {
    PopupMenu menu = PopupMenu(
      context: context,
      items: textMenuItems!,
      onClickMenu: (item) {
        onClickMenu?.call(item, message);
      },
      config: const MenuConfig(itemHeight: 40),
      onDismiss: () {},
    );
    menu.show(widgetKey: message.ext.itemKey);
  }
}
