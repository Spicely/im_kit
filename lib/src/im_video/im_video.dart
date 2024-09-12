part of im_kit;

class ImVideo extends ImBase {
  const ImVideo({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
    super.onTapDownFile,
    super.onTapPlayVideo,
    super.contextMenuBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return getSelectableView(
      context,
      Stack(
        key: ValueKey(msg.clientMsgID),
        children: [
          CachedImage(file: ext.previewFile, width: 180, height: 290, circular: 5, imageUrl: msg.videoElem?.snapshotUrl, fit: BoxFit.cover),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (ext.isDownloading) return;
                    if (ext.file == null) {
                      onTapDownFile?.call(message);
                    } else {
                      onTapPlayVideo?.call(message);
                    }
                  },
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
                                : ext.file == null
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
            ),
          ),
          Positioned(
            bottom: 4,
            right: 6,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(message.m.createTime?.formatDate() ?? '', style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
