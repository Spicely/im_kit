part of im_kit;

class ImVideo extends ImBase {
  final void Function(Message message)? onTapDownFile;

  const ImVideo({
    Key? key,
    required bool isMe,
    required MessageExt message,
    this.onTapDownFile,
  }) : super(key: key, isMe: isMe, message: message);

  (double w, double h) get size {
    double width = msg.videoElem?.snapshotWidth?.toDouble() ?? 240.0;
    double height = msg.videoElem?.snapshotHeight?.toDouble() ?? 240.0;

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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          CachedImage(
            memory: ext.preview,
            file: ext.previewPath != null ? File(ext.previewPath!) : null,
            width: w,
            height: h,
            circular: 5,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(
              child: Stack(
                children: [
                  const SizedBox(width: 50, height: 50),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Center(
                        child: ext.isDownloading
                            ? Text(
                                '${((ext.progress ?? 0) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white),
                              )
                            : ext.path == null
                                ? Transform.rotate(
                                    angle: -pi / 2,
                                    child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
                                  )
                                : const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 3,
                        backgroundColor: Colors.white,
                        value: ext.isDownloading ? ext.progress : 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
