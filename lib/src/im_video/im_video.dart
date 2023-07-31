part of im_kit;

class ImVideo extends ImBase {
  final void Function(Message message)? onTapDownFile;

  const ImVideo({
    Key? key,
    required bool isMe,
    required Message message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  ImExtModel? get ext => message.extModel;

  (double w, double h) get size {
    double width = message.videoElem?.snapshotWidth?.toDouble() ?? 240.0;
    double height = message.videoElem?.snapshotHeight?.toDouble() ?? 240.0;

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
    return FutureBuilder(
      future: ImCore.checkFileExist(message, isMe, fileSize: message.fileElem?.fileSize),
      builder: (BuildContext context, AsyncSnapshot<(bool, ImExtModel?)> snapshot) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              CachedImage(
                imageUrl: message.videoElem?.snapshotUrl,
                width: w,
                height: h,
                circular: 5,
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Text('111'),
                // child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}
