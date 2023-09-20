part of im_kit;

class ImPlayer extends StatefulWidget {
  /// 当前显示的消息
  final MessageExt message;

  /// 保存成功
  final void Function()? onSaveSuccess;

  /// 保存失败
  final void Function()? onSaveFailure;

  const ImPlayer({
    super.key,
    required this.message,
    this.onSaveSuccess,
    this.onSaveFailure,
  });

  @override
  State<ImPlayer> createState() => _ImPlayerState();
}

class _ImPlayerState extends State<ImPlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    videoPlayerController = VideoPlayerController.file(File(widget.message.ext.path!));
    await videoPlayerController.initialize();
    chewieController = ChewieController(videoPlayerController: videoPlayerController, autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          if (chewieController != null) Chewie(controller: chewieController!),
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
      MessageExt message = widget.message;
      String url = message.m.videoElem!.videoUrl!;

      String suffix = url.substring(url.lastIndexOf('.'));
      String fileName = '${DateTime.now().millisecondsSinceEpoch}$suffix';
      await ImageGallerySaver.saveFile(message.ext.path!, isReturnPathOfIOS: true, name: fileName);
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('保存图片失败: $e');
      widget.onSaveFailure?.call();
    }
  }
}
