part of im_kit;

class VoiceRecordController extends GetxController {
  /// 完成录音
  final Function(String, int)? onStopRecord;

  /// 录音时间不足
  final Function()? onRecordTimeShort;

  /// 取消发送
  final Function()? onCancelRecord;

  VoiceRecordController({this.onStopRecord, this.onRecordTimeShort, this.onCancelRecord});

  /// 显示录制
  RxBool isShowing = false.obs;

  /// 录音实例
  final AudioRecorder record = AudioRecorder();

  /// 保存文件路径
  final String _path = join(ImCore.dirPath, 'FileRecv', OpenIM.iMManager.uid);

  String _filePath = '';

  /// 录音时间
  DateTime startTime = DateTime.now();

  String fileName = '';

  /// 滑动距离
  double panY = 0;

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    ///  创建文件目录
    Directory(_path).create(recursive: true);
    super.onReady();
  }

  /// 开始录音
  void startVoiceRecord(TapDownDetails details) async {
    panY = 0;
    isShowing.value = true;
    startTime = DateTime.now();
    fileName = startTime.millisecondsSinceEpoch.toString();
    _filePath = '$_path/$fileName.m4a';
    await record.start(const RecordConfig(), path: _filePath);
  }

  void onPanUpdate(DragUpdateDetails details) {
    panY = Get.height - details.globalPosition.dy;
  }

  void onPanEnd(DragEndDetails details) async {
    if (!isShowing.value) return;
    isShowing.value = false;
    // double fingerPositionY = details;
    // print(fingerPositionY);

    /// 判断手指距离
    if (panY > 200) {
      await record.stop();
      File(_filePath).delete();
      onCancelRecord?.call();
    } else {
      _stopRecord();
    }
  }

  /// 结束录音
  void stopVoiceRecord(TapUpDetails details) {
    if (!isShowing.value) return;
    isShowing.value = false;
    _stopRecord();
  }

  /// 结束录制
  void _stopRecord() async {
    await record.stop();
    DateTime time = DateTime.now();
    if (time.difference(startTime).inSeconds < 1) {
      onRecordTimeShort?.call();
      return;
    }
    onStopRecord?.call(_filePath, time.difference(startTime).inSeconds);
    _filePath = '';
  }
}
