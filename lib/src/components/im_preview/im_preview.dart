part of im_kit;

class ImPreview extends StatefulWidget {
  final List<MessageExt> messages;

  /// 当前显示的消息
  final MessageExt currentMessage;

  /// 保存成功
  final void Function()? onSaveSuccess;

  /// 保存失败
  final void Function()? onSaveFailure;

  final Future<void> Function(String)? onSaveBefore;

  const ImPreview({
    super.key,
    required this.messages,
    required this.currentMessage,
    this.onSaveSuccess,
    this.onSaveFailure,
    this.onSaveBefore,
  });

  @override
  State<ImPreview> createState() => _ImPreviewState();
}

class _ImPreviewState extends State<ImPreview> {
  late List<MessageExt> messages;
  late PageController pageController;
  int currentIndex = 0;

  @override
  initState() {
    /// 排除掉非图片消息
    messages = widget.messages.where((v) => v.m.contentType == MessageType.picture).toList();
    currentIndex = messages.indexWhere((v) => v.m.clientMsgID == widget.currentMessage.m.clientMsgID);
    pageController = PageController(initialPage: currentIndex);
    super.initState();
  }

  (double w, double h) getSize(MessageExt message) {
    double width = message.m.pictureElem?.sourcePicture?.width?.toDouble() ?? 240.0;
    double height = message.m.pictureElem?.sourcePicture?.height?.toDouble() ?? 240.0;

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
    ImLanguage language = ImKitTheme.of(context).language;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              MessageExt message = messages[index];
              final (w, h) = getSize(message);
              return PhotoViewGalleryPageOptions(
                // imageProvider: message.ext.file == null ? NetworkImage(message.m.pictureElem?.snapshotPicture?.url ?? '') as ImageProvider<Object>? : FileImage(message.ext.file!),
                imageProvider: NetworkImage(message.m.pictureElem?.snapshotPicture?.url ?? ''),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.contained * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: ValueKey(message.m.clientMsgID)),
                errorBuilder: (context, error, stackTrace) {
                  return CachedImage(file: message.ext.file!, width: w, height: h, circular: 5, fit: BoxFit.cover);
                },
              );
            },
            itemCount: messages.length,
            loadingBuilder: loadingBuilder,
            pageController: pageController,
            onPageChanged: onPageChanged,
          ),
          if (!Utils.isDesktop) _buildBackBtn(),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: saveImage,
                    child: Container(
                      width: 100,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(language.save, style: const TextStyle(fontSize: 14, color: Colors.white)),
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

  Widget _buildBackBtn() => Positioned(
        top: 50,
        left: 20,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: Get.back,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black87.withOpacity(0.4),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
      );

  void onPageChanged(int index) {
    currentIndex = index;
  }

  Widget loadingBuilder(BuildContext context, ImageChunkEvent? event) {
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: (event == null || null == event.expectedTotalBytes) ? null : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// 保存图片到相册
  Future<void> saveImage() async {
    try {
      MessageExt message = messages[currentIndex];
      if (widget.onSaveBefore != null) {
        await widget.onSaveBefore!(message.ext.file!.path);
      }
      await ImKitIsolateManager.saveFileToAlbum(message.ext.file!.path);
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('保存图片失败: $e');
      widget.onSaveFailure?.call();
    }
  }
}
