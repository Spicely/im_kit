part of im_kit;

extension ExtensionMessage on Message {
  MessageExt toExt(String secretKey) {
    final ext = ImExtModel(createTime: DateTime.now());
    switch (contentType) {
      case MessageType.card:
        var data = json.decode(content ?? '{}');
        ext.data = data;
        break;
      case MessageType.location:
        var data = json.decode(locationElem?.description ?? '{}');
        ext.data = data;
        break;
      case MessageType.voice:
      case MessageType.file:
      case MessageType.picture:

        /// 优先判断本地文件
        String? filePath = soundElem?.soundPath ?? videoElem?.videoPath ?? fileElem?.filePath ?? pictureElem?.sourcePath;
        if (filePath != null && File(filePath).existsSync()) {
          ImKitIsolateManager.decryptFile(secretKey, filePath);
          ext.path = filePath;
          break;
        }
        filePath = ImCore.getSavePath(this);
        if (File(filePath).existsSync()) {
          ImKitIsolateManager.decryptFile(secretKey, filePath);
          ext.path = filePath;
        }
        ext.secretKey = _getSecretKey(this, secretKey);
        var (width, height) = _computedSize(width: pictureElem?.sourcePicture?.width?.toDouble(), height: pictureElem?.sourcePicture?.height?.toDouble());
        ext.width = width;
        ext.height = height;
        break;
      case MessageType.video:
        String? snapshotPath = videoElem?.snapshotPath;
        String? videoPath = videoElem?.videoPath;
        if (snapshotPath != null && File(snapshotPath).existsSync()) {
          ImKitIsolateManager.decryptFile(secretKey, snapshotPath);
          ext.previewPath = snapshotPath;
          break;
        }
        if (videoPath != null && File(videoPath).existsSync()) {
          ImKitIsolateManager.decryptFile(secretKey, videoPath);
          ext.path = videoPath;
          break;
        }
        String? url = videoElem?.snapshotUrl;

        if (url != null) {
          String fileName = url.split('/').last;
          String previewPath = join(ImCore.saveDir, fileName);
          if (File(previewPath).existsSync()) {
            ImKitIsolateManager.decryptFile(secretKey, previewPath);
            ext.previewPath = previewPath;
          }
        }
        String? videoUrl = videoElem?.videoUrl;
        if (videoUrl != null) {
          String fileName = videoUrl.split('/').last;
          String videoPath = join(ImCore.saveDir, fileName);
          if (File(videoPath).existsSync()) {
            ImKitIsolateManager.decryptFile(secretKey, videoPath);
            ext.path = videoPath;
          }
        }
        ext.secretKey = _getSecretKey(this, secretKey);
        var (width, height) = _computedSize(width: videoElem?.snapshotWidth?.toDouble(), height: videoElem?.snapshotHeight?.toDouble());
        ext.width = width;
        ext.height = height;
        break;
      default:
    }

    return MessageExt(
      ext: ext,
      m: this,
    );
  }

  /// 消息类型
  String get type => switch (contentType) {
        MessageType.picture => isSingleChat ? '[图片]' : '$senderNickname: [图片]',
        MessageType.file => isSingleChat ? '[文件]' : '$senderNickname: [文件]',
        MessageType.video => isSingleChat ? '[视频]' : '$senderNickname: [视频]',
        MessageType.voice => isSingleChat ? '[语音]' : '$senderNickname: [语音]',
        MessageType.location => isSingleChat ? '[位置]' : '$senderNickname: [位置]',
        MessageType.advancedRevoke => isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]',
        MessageType.text || MessageType.advancedText => isSingleChat ? atElem?.text ?? content ?? '' : '$senderNickname: ${atElem?.text ?? content ?? ''}',
        MessageType.at_text => _getAtText(this),
        _ => '暂不支持的消息',
      };
}

extension ExtensionConversationInfo on ConversationInfo {
  String title({int? number}) {
    if (isGroupChat) {
      return number != null && number != 0 ? '$showName($number)' : showName ?? '';
    } else {
      try {
        Map<String, dynamic> map = jsonDecode(showName ?? '{}');
        return Utils.getValue(map['remark'], map['nickname']) ?? showName ?? '';
      } catch (e) {
        return showName ?? '';
      }
    }
  }
}
