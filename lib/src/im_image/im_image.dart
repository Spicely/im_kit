part of im_kit;

class ImImage extends ImBase {
  const ImImage({
    Key? key,
    required bool isMe,
    required MessageExt message,
  }) : super(key: key, isMe: isMe, message: message);

  (double w, double h) get size {
    double width = msg.pictureElem?.sourcePicture?.width?.toDouble() ?? 240.0;
    double height = msg.pictureElem?.sourcePicture?.height?.toDouble() ?? 240.0;

    /// 获取宽高比
    double ratio = width / height;

    /// 如果宽高比大于1，说明是横图，需要限制宽度
    if (ratio > 1) {
      width = 240.0;
      height = width / ratio;
    } else {
      height = 240.0;
      width = height * ratio;
    }

    return (width, height);
  }

  @override
  Widget build(BuildContext context) {
    final (w, h) = size;

    /// 获取像素密度
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    String crop = '?x-oss-process=image/resize,m_fill,h_${(h * pixelRatio).toInt()},w_${(w * pixelRatio).toInt()}';
    String? url = msg.pictureElem?.sourcePicture?.url;
    return Hero(
      tag: ValueKey(msg.clientMsgID),
      child: CachedImage(
        imageUrl: url != null ? '$url$crop' : null,
        file: msg.pictureElem?.sourcePath != null ? File(msg.pictureElem?.sourcePath ?? '') : null,
        width: w,
        height: h,
        circular: 5,
        fit: BoxFit.cover,
      ),
    );
  }
}
