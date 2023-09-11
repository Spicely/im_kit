part of im_kit;

class VoiceRecord extends StatelessWidget {
  final Widget Function(VoiceRecordController) child;

  /// 完成录音
  final Function(String, int)? onStopRecord;

  /// 录音时间不足
  final Function()? onRecordTimeShort;

  /// 取消发送
  final Function()? onCancelRecord;

  const VoiceRecord({
    super.key,
    required this.child,
    this.onStopRecord,
    this.onRecordTimeShort,
    this.onCancelRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GetBuilder(
        init: VoiceRecordController(onRecordTimeShort: onRecordTimeShort, onStopRecord: onStopRecord, onCancelRecord: onCancelRecord),
        builder: (controller) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: controller.onPanUpdate,
          onPanEnd: controller.onPanEnd,
          child: Stack(
            children: [
              child(controller),
              Obx(
                () => Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Offstage(
                    offstage: !controller.isShowing.value,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox()),
                          // 裁切的控件
                          const Text('松开立即发送 上滑取消', style: TextStyle(color: Colors.white)),
                          Stack(
                            children: [
                              ClipPath(
                                // 只裁切底部的方法
                                clipper: ArcClipper(),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.white,
                                ),
                              ),
                              ClipPath(
                                // 只裁切底部的方法
                                clipper: ArcClipper(),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.1),
                                        Colors.white,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      stops: const [0.1, 1],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 60),
                                    child: Text('长按录制语音', style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // 路径
    var path = Path();
    // 设置路径的开始点
    path.moveTo(0, size.height);
    // 绘制直线到顶部左侧
    path.lineTo(0, 70);

    // 设置曲线的开始样式
    var firstControlPoint = Offset(size.width / 2, 0);
    // 设置曲线的结束样式
    var firstEndPoint = Offset(size.width, 70);
    // 把设置的曲线添加到路径里面
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    // 绘制直线到顶部右侧
    path.lineTo(size.width, size.height);

    // 返回路径
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
