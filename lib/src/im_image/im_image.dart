part of im_kit;

class ImImage extends StatelessWidget {
  final Message message;

  const ImImage({super.key, required this.message});

  (double w, double h) get size {
    double width = message.pictureElem?.sourcePicture?.width?.toDouble() ?? 240.0;
    double height = message.pictureElem?.sourcePicture?.height?.toDouble() ?? 240.0;

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
    String? url = message.pictureElem?.sourcePicture?.url;
    return Hero(
      tag: ValueKey(message.clientMsgID),
      child: CachedImage(
        imageUrl: url != null ? '$url$crop' : null,
        width: w,
        height: h,
        circular: 5,
      ),
    );
  }
}
