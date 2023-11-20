part of im_kit;
/*
 * Summary:  语音录音/播放/发送
 * Created Date: 2023-04-24 17:37:01
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-19 11:52:23
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class ImBottomVoice extends StatefulWidget {
  final Function()? onVoiceStart;

  final Function()? onVoiceEnd;

  /// 发送语音
  final Function(String path, int duration) onVoiceSend;

  /// 没有权限
  final Function()? onRecordNotPermission;

  /// 最小录制时间
  final Duration minDuration;

  /// 是否禁言
  final bool isMute;

  const ImBottomVoice({
    super.key,
    this.onVoiceStart,
    this.onVoiceEnd,
    this.minDuration = const Duration(seconds: 1),
    required this.onVoiceSend,
    this.onRecordNotPermission,
    required this.isMute,
  });

  @override
  State<ImBottomVoice> createState() => _ImBottomVoiceState();
}

class _ImBottomVoiceState extends State<ImBottomVoice> {
  /// 录音实例
  // final AudioRecorder record = AudioRecorder();

  /// 是否正在录音
  bool isRecording = false;

  /// 保存文件路径
  final String path = '${ImCore.dirPath}/voice';

  @override
  initState() {
    super.initState();

    ///  创建文件目录
    Directory(path).create();
  }

  /// 录制时间
  DateTime time = DateTime.now();

  /// 录制时间
  int duration = 0;

  Timer? timer;

  /// 文件名
  String fileName = '';

  @override
  void didUpdateWidget(covariant ImBottomVoice oldWidget) {
    if (widget.isMute && isRecording) {
      cancelRecordVoice();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    return Stack(
      children: [
        Container(
          height: isRecording ? 65 + 240 : 240,
          width: double.infinity,
          color: const Color.fromRGBO(241, 241, 241, 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isRecording ? _buildRecordVoice(context) : _buildPlayVoice(language),
            ],
          ),
        ),
        if (isRecording)
          Positioned(
            child: TextButton(
              onPressed: cancelRecordVoice,
              child: Text(
                language.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildPlayVoice(ImLanguage language) {
    return GestureDetector(
      onTap: () {
        widget.onVoiceStart?.call();
        recordVoice();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CachedImage(width: 110, height: 110, assetUrl: 'assets/icons/play.png', package: 'im_kit'),
          const SizedBox(height: 12),
          Text(language.longPressRecordVoice, style: const TextStyle(fontSize: 14, color: Color.fromRGBO(175, 175, 175, 1))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    // record.dispose();
    super.dispose();
  }

  /// 取消录音
  void cancelRecordVoice() {
    widget.onVoiceEnd?.call();
    setState(() {
      isRecording = false;
    });
    timer?.cancel();
    duration = 0;
    // record.stop();
  }

  /// 录音
  void recordVoice() async {
    /// 获取录音权限
    // if (await record.hasPermission()) {
    //   time = DateTime.now();
    //   fileName = const Uuid().v4();
    //   setState(() {
    //     isRecording = true;
    //     duration = 0;
    //   });
    //   startTimer();
    //   // record.start(const RecordConfig(), path: '$path/$fileName.m4a');
    // } else {
    //   widget.onRecordNotPermission?.call();
    // }
  }

  /// 开始计时
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        duration++;
      });
    });
  }

  /// 结束语音录制
  void endRecordVoice() {
    DateTime currentTime = DateTime.now();
    setState(() {
      isRecording = false;
    });
    timer?.cancel();
    duration = 0;
    // record.stop();
    if (currentTime.difference(time) < widget.minDuration) {
      // widget.onRecordError?.call();
      return;
    }
    widget.onVoiceSend.call('$path/$fileName.m4a', currentTime.difference(time).inSeconds);
  }

  Widget _buildRecordVoice(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    return GestureDetector(
      onTap: () {
        widget.onVoiceEnd?.call();
        endRecordVoice();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 123,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    // clipBehavior: Clip.none,
                    children: [
                      const SizedBox(height: 48, width: 70),
                      Positioned(
                        left: -50,
                        child: Lottie.asset(
                          'assets/images/voice_record_2.json',
                          package: 'im_kit',
                          height: 40,
                          animate: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text('$duration"', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const CachedImage(
            width: 80,
            height: 80,
            assetUrl: 'assets/icons/duringRecording.png',
          ),
          const SizedBox(height: 12),
          Text(language.recording, style: const TextStyle(fontSize: 14, color: Color.fromRGBO(175, 175, 175, 1))),
        ],
      ),
    );
  }
}
