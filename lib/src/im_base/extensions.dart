part of im_kit;

extension ExtensionAdvancedMessage on AdvancedMessage {
  List<MessageExt> toExt(String secretKey) {
    return (messageList ?? []).map((e) {
      if (e.contentType == MessageType.quote) {
        MessageExt extMsg = e.toExt(secretKey);
        extMsg.ext.quoteMessage = extMsg.m.quoteElem!.quoteMessage!.toExt(secretKey);
        return extMsg;
      } else {
        return e.toExt(secretKey);
      }
    }).toList();
  }
}

extension ExtensionMessage on Message {
  MessageExt toExt(String secretKey) {
    final ext = ImExtModel(createTime: DateTime.now());
    switch (contentType) {
      case MessageType.at_text:
      case MessageType.text:
      case MessageType.quote:
        {
          String v = EncryptExtends.DEC_STR_AES_UTF8_ZP(plainText: atElem?.text ?? atElem?.text ?? quoteElem?.text ?? content ?? '', keyStr: secretKey);
          List<AtUserInfo> atUsersInfo = atElem?.atUsersInfo ?? [];

          List<ImAtTextType> list = [];

          /// 匹配艾特用户
          String atReg = atUsersInfo.map((v) => '@${v.atUserID} ').join('|');

          var regexEmoji = _emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

          /// 匹配电话号码
          String phoneReg = r"\b\d{5,}\b";

          /// 匹配网址
          String urlRge = r'(((http(s)?:\/\/(www\.)?)|(www\.))([-a-zA-Z0-9@:;_\+.%#?&\/=]*))|([-a-zA-Z@:;_\+.%#?&\/=]{2,}\.((com)|(cn)))/g';

          /// 匹配邮箱
          String email = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
          String regExp;
          if (atUsersInfo.isEmpty) {
            regExp = [regexEmoji, urlRge, email, phoneReg].join('|');
          } else {
            regExp = [regexEmoji, urlRge, atReg, email, phoneReg].join('|');
          }
          v.splitMapJoin(
            RegExp('($regExp)'),
            onMatch: (Match m) {
              String value = m.group(0)!;
              if (RegExp(urlRge).hasMatch(value)) {
                list.add(ImAtTextType(type: ImAtType.url, text: value.trimRight()));
              } else if (RegExp(regexEmoji).hasMatch(value)) {
                String emoji = _emojiFaces[value]!;
                list.add(ImAtTextType(type: ImAtType.emoji, text: emoji));
              } else if (RegExp(email).hasMatch(value)) {
                list.add(ImAtTextType(type: ImAtType.email, text: value));
              } else if (RegExp(atReg).hasMatch(value)) {
                String id = value.replaceAll('@', '').trim();
                AtUserInfo? atUserInfo = atUsersInfo.firstWhereOrNull((v) => v.atUserID == id);
                if (atUserInfo == null) {
                  if (RegExp(phoneReg).hasMatch(value)) {
                    list.add(ImAtTextType(type: ImAtType.phone, text: value));
                  } else {
                    list.add(ImAtTextType(type: ImAtType.text, text: value));
                  }
                } else {
                  if (atUserInfo.atUserID == OpenIM.iMManager.uid) {
                    list.add(ImAtTextType(type: ImAtType.at, text: '@你 ', userInfo: atUserInfo));
                  } else {
                    list.add(ImAtTextType(type: ImAtType.at, text: '@${atUserInfo.groupNickname} ', userInfo: atUserInfo));
                  }
                }
              } else if (RegExp(phoneReg).hasMatch(value)) {
                list.add(ImAtTextType(type: ImAtType.phone, text: value));
              }
              return '';
            },
            onNonMatch: (String n) {
              list.add(ImAtTextType(type: ImAtType.text, text: n));
              return '';
            },
          );
          if (contentType == MessageType.quote) {
            ext.quoteMessage = quoteElem?.quoteMessage?.toExt(secretKey);
          }

          ext.data = list;
        }
        break;
      case MessageType.card:
        var data = json.decode(content ?? '{}');
        ext.data = data;
        break;
      case MessageType.location:
        var data = json.decode(locationElem?.description ?? '{}');
        ext.data = data;
        break;
      case MessageType.custom:
        var data = json.decode(customElem?.data ?? '{}');
        ext.data = data;
        break;

      case MessageType.groupMemberMutedNotification:
      case MessageType.groupMemberCancelMutedNotification:
      case MessageType.memberInvitedNotification:
      case MessageType.groupInfoSetNotification:
      case MessageType.memberEnterNotification:
      case MessageType.memberKickedNotification:
        var data = json.decode(notificationElem?.detail ?? '{}');
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
        } else {
          filePath = ImCore.getSavePath(this);
          if (File(filePath).existsSync()) {
            ImKitIsolateManager.decryptFile(secretKey, filePath);
            ext.path = filePath;
          }
        }
        ext.secretKey = _getSecretKey(this, secretKey);
        var (width, height) = _computedSize(width: pictureElem?.sourcePicture?.width?.toDouble(), height: pictureElem?.sourcePicture?.height?.toDouble());
        ext.width = width;
        ext.height = height;
        break;
      case 300:
        Map<String, dynamic> map = jsonDecode(content ?? '{}');
        ext.data = jsonDecode(map['data'] ?? '{}');

        /// 获取文件名
        String fileName = (ext.data['url'] as String).split('/').last;

        /// 优先判断本地文件
        String? filePath = '${ImCore.dirPath}/emoji/${ext.data['emoticons_id']}/$fileName';
        if (File(filePath).existsSync()) {
          ext.path = filePath;
        }
        ext.secretKey = _getSecretKey(this, secretKey);
        var (width, height) = _computedSize(width: map['w'] ?? 120, height: map['h'] ?? 120);
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
  InlineSpan get type => switch (contentType) {
        MessageType.picture => TextSpan(text: isSingleChat ? '[图片]' : '$senderNickname: [图片]'),
        MessageType.file => TextSpan(text: isSingleChat ? '[文件]' : '$senderNickname: [文件]'),
        MessageType.video => TextSpan(text: isSingleChat ? '[视频]' : '$senderNickname: [视频]'),
        MessageType.voice => TextSpan(text: isSingleChat ? '[语音]' : '$senderNickname: [语音]'),
        MessageType.location => TextSpan(text: isSingleChat ? '[位置]' : '$senderNickname: [位置]'),
        MessageType.card => TextSpan(text: isSingleChat ? '[用户名片]' : '$senderNickname: [用户名片]'),
        MessageType.merger => TextSpan(text: isSingleChat ? '[合并消息]' : '$senderNickname: [合并消息]'),
        MessageType.advancedRevoke => TextSpan(text: isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]'),
        MessageType.text || MessageType.advancedText || MessageType.at_text => _getAtText(this),
        MessageType.revoke => TextSpan(text: '$senderNickname撤回了一条消息'),
        300 => TextSpan(text: isSingleChat ? '[表情]' : '$senderNickname: [表情]'),
        MessageType.groupMemberMutedNotification => _getGroupMemberMutedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.groupMemberCancelMutedNotification => _getGroupMemberCancelMutedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberInvitedNotification => _getMemberInvitedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberEnterNotification => _getMemberEnterNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.custom => switch (jsonDecode(customElem?.data ?? '{}')['contentType']) {
            81 => const TextSpan(text: '[红包消息]'),
            82 => TextSpan(text: '$senderNickname领取了你的红包'),
            83 => const TextSpan(text: '[转账消息]'),
            84 => const TextSpan(text: '[红包退还消息]'),
            _ => const TextSpan(text: '暂不支持的消息'),
          },
        _ => const TextSpan(text: '暂不支持的消息'),
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
