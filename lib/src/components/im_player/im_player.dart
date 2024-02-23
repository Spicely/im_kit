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
  late final player = Player();

  late final videoController = VideoController(player);

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> init() async {
    player.open(Media('file://${widget.message.ext.file!.path}'));
  }

  @override
  Widget build(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Video(controller: videoController),
          ),
          if (Utils.isMobile)
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          if (!Utils.isDesktop)
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
                      onTap: saveVideo,
                      child: Container(
                        width: 100,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          language.save,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
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

  /// 保存视频到相册
  Future<void> saveVideo() async {
    try {
      MessageExt message = widget.message;
      String url = message.m.videoElem!.videoUrl!;

      String suffix = url.substring(url.lastIndexOf('.'));
      String fileName = '${DateTime.now().millisecondsSinceEpoch}$suffix';
      await ImageGallerySaver.saveFile(message.ext.file!.path, isReturnPathOfIOS: true, name: fileName);
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('保存视频失败: $e');
      widget.onSaveFailure?.call();
    }
  }
}
