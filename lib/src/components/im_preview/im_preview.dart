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
  late ExtendedPageController pageController;
  int currentIndex = 0;
  // var currentIndex = 0.obs;

  @override
  initState() {
    /// 排除掉非图片消息
    messages = widget.messages.where((v) => v.m.contentType == MessageType.picture).toList();
    currentIndex = messages.indexWhere((v) => v.m.clientMsgID == widget.currentMessage.m.clientMsgID);
    pageController = ExtendedPageController(initialPage: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Container(
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          Center(
            child: SizedBox(
              width: Utils.isDesktop ? Get.width * 0.6 : null,
              child: ExtendedImageGesturePageView.builder(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  MessageExt message = messages[index];
                  return Hero(
                    tag: ValueKey(message.m.clientMsgID),
                    child: ExtendedImage.file(
                      message.ext.file!,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.gesture,
                      initEditorConfigHandler: (state) {
                        return EditorConfig(maxScale: 6.0);
                      },
                    ),
                  );
                },
                itemCount: messages.length,
                onPageChanged: onPageChanged,
              ),
            ),
          ),
          Positioned(
            // 假设子widget宽度为50
            left: 25,
            top: (MediaQuery.of(context).size.height - 50) / 2,
            // width: 32,
            // height: 32,
            child: Visibility(
              visible: currentIndex == 0 ? false : true,
              maintainState: true,
              child: GestureDetector(
                // child: Image.asset('assets/icons/pre_image.png', width: 32, height: 32, package: 'im_kit'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: Colors.black, // 设置所有角的半径为20
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  // 按钮点击时的处理逻辑
                  // print('pre_image');
                  // pageController.nextPage(duration: duration, curve: curve)
                  debugPrint('page:${pageController.page}');
                  if (currentIndex > 0) {
                    debugPrint('page:${pageController.page}');
                    pageController.previousPage(duration: const Duration(milliseconds: 1), curve: Curves.easeIn);
                  }
                },
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: (MediaQuery.of(context).size.height - 50) / 2,
            child: Visibility(
              visible: currentIndex == messages.length - 1 ? false : true,
              maintainState: true,
              child: GestureDetector(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: Colors.black, // 设置所有角的半径为20
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  // 按钮点击时的处理逻辑
                  // pageController.nextPage(duration: const Duration(milliseconds: 1), curve: Curves.easeIn);
                  // print('page:${pageController.page} total:${currentIndex}');
                  if (currentIndex < messages.length - 1) {
                    pageController.nextPage(duration: const Duration(milliseconds: 1), curve: Curves.easeIn);
                    debugPrint('next_image');
                  }
                },
              ),
            ),
          ),
          _buildBackBtn(),
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
    setState(() {
      currentIndex = index;
    });
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
      await ImKitIsolateManager.saveFileToAlbum(message.ext.file!.path, fileName: basenameWithoutExtension(message.m.pictureElem?.sourcePicture?.url ?? ''));
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('保存图片失败: $e');
      widget.onSaveFailure?.call();
    }
  }
}
