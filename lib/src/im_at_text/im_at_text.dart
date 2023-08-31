part of im_kit;

class ImAtText extends ImBase {
  const ImAtText({
    super.key,
    required super.isMe,
    required super.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: theme.themeColor, borderRadius: theme.borderRadius),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: theme.padding,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(message.m.textElem?.content ?? ''),
      ),
    );
  }
}
