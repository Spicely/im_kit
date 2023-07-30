part of im_kit;

class VoiceRecordController extends GetxController {
  /// 完成录音
  final Function(String, int)? onStopRecord;

  /// 录音时间不足
  final Function()? onRecordTimeShort;

  VoiceRecordController({this.onStopRecord, this.onRecordTimeShort});

  /// 显示录制
  RxBool isShowing = false.obs;

  /// 录音实例
  final AudioRecorder record = AudioRecorder();

  /// 保存文件路径
  final String _path = join(ImCore.dirPath, 'FileRecv', OpenIM.iMManager.uid, 'voice');

  String _filePath = '';

  /// 录音时间
  DateTime startTime = DateTime.now();

  String fileName = '';

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
  void startVoiceRecord() async {
    isShowing.value = true;
    startTime = DateTime.now();
    fileName = startTime.millisecondsSinceEpoch.toString();
    _filePath = '$_path/$fileName.m4a';
    await record.start(const RecordConfig(), path: _filePath);
  }

  void onPanEnd(DragEndDetails details) {
    if (!isShowing.value) return;
    isShowing.value = false;
    _stopRecord();
  }

  /// 结束录音
  void stopVoiceRecord() {
    if (!isShowing.value) return;
    isShowing.value = false;
    _stopRecord();
  }

  /// 结束录制
  void _stopRecord() async {
    record.stop();
    DateTime time = DateTime.now();
    if (time.difference(startTime).inSeconds < 1) {
      onRecordTimeShort?.call();

      return;
    }
    onStopRecord?.call(_filePath, time.difference(startTime).inSeconds);
    _filePath = '';
  }
}
