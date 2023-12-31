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
                imageProvider: FileImage(File(message.ext.path!)),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.contained * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: ValueKey(message.m.clientMsgID)),
                errorBuilder: (context, error, stackTrace) {
                  return CachedImage(file: File(message.ext.path!), width: w, height: h, circular: 5, fit: BoxFit.cover);
                },
              );
            },
            itemCount: messages.length,
            loadingBuilder: loadingBuilder,
            pageController: pageController,
            onPageChanged: onPageChanged,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: context.theme.appBarTheme.iconTheme?.copyWith(color: Colors.white),
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemStatusBarContrastEnforced: false,
              ),
              leading: IconButton(
                icon: const Icon(Icons.close_outlined, color: Colors.white),
                onPressed: Get.back,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                spacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  GestureDetector(
                    onTap: saveImage,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  // Container(
                  //   width: 30,
                  //   height: 30,
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.withOpacity(0.8),
                  //     borderRadius: BorderRadius.circular(15),
                  //   ),
                  //   child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      String url = message.m.pictureElem!.sourcePicture!.url!;

      /// 检测文件是否存在
      final result = await ImCore.checkFileExist(message.m, false);
      if (result.$1) {
        String suffix = url.substring(url.lastIndexOf('.'));
        String fileName = '${DateTime.now().millisecondsSinceEpoch}$suffix';
        if (widget.onSaveBefore != null) {
          await widget.onSaveBefore!(result.$2!.path!);
        }
        await ImageGallerySaver.saveFile(result.$2!.path!, isReturnPathOfIOS: true, name: fileName);
      } else {
        String savePath = ImCore.getSavePath(message.m);
        await Dio().download(url, savePath);

        String suffix = url.substring(url.lastIndexOf('.'));
        String fileName = '${DateTime.now().millisecondsSinceEpoch}$suffix';
        if (widget.onSaveBefore != null) {
          await widget.onSaveBefore!(savePath);
        }
        await ImageGallerySaver.saveFile(savePath, isReturnPathOfIOS: true, name: fileName);
      }
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('保存图片失败: $e');
      widget.onSaveFailure?.call();
    }
  }
}
