part of im_kit;

class _IsolateFun {
  /// 加密文件
  static Future<void> encryptFile(String key, String path, {String iv = 'abcd1234abcd1234'}) async {
    final fileByte = File(path).readAsBytesSync();

    DecDataRes res2 = DecDataRes.fromByUint8list(fileByte, key, decIV: enc.IV.fromUtf8(iv));
    if (res2.isEncData != 0) return;
    Uint8List encdata = res2.encData;

    /// 写入加密后的文件
    File file = File(path);
    await file.writeAsBytes(encdata, flush: true);
  }

  /// 解开密文件
  static Future<void> decryptFile(String key, String filePath, {String iv = 'abcd1234abcd1234'}) async {
    final fileByte = await File(filePath).readAsBytes();
    DecDataRes res2 = DecDataRes.fromByUint8list(fileByte, key, decIV: enc.IV.fromUtf8(iv));
    if (res2.isEncData == 0) {
      return;
    }
    Uint8List decData = res2.decFile;
    File file = File(filePath);
    await file.writeAsBytes(decData, flush: true);

    /// 延迟1s 避免文件还未写入完成
    await Future.delayed(const Duration(seconds: 1));
  }

  /// 转成MessageExt
  static Future<MessageExt> toMessageExt(Message msg, String secretKey) async {
    final ext = ImExtModel(key: GlobalKey(), createTime: DateTime.now());
    // SelectionAreaWidgetController controller=
    ext.controller = SelectionAreaWidgetController(
        globalKey: ext.key,
        // ctxMenuctr:ctxcontroller,
        screenHeight: 770.0,
        safeBot: 56,
        safeTop: 56);
    if (msg.sendTime != null) {
      ext.time = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(msg.sendTime!));
    }

    /// 阅后即焚
    ext.isPrivateChat = msg.attachedInfoElem?.isPrivateChat ?? false;
    try {
      switch (msg.contentType) {
        case MessageType.at_text:
        case MessageType.text:
        case MessageType.quote:
          {
            String v = EncryptExtends.DEC_STR_AES_UTF8_ZP(plainText: msg.atTextElem?.text ?? msg.atTextElem?.text ?? msg.quoteElem?.text ?? msg.textElem?.content ?? '', keyStr: secretKey);
            List<AtUserInfo> atUsersInfo = msg.atTextElem?.atUsersInfo ?? [];

            List<ImAtTextType> list = [];

            /// 匹配艾特用户
            String atReg = atUsersInfo.map((v) => '@${v.atUserID} ').join('|');

            var regexEmoji = ImCore.emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

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
                  String emoji = ImCore.emojiFaces[value]!;
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
                    if (atUserInfo.atUserID == ImCore._uid) {
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
            if (msg.contentType == MessageType.quote) {
              ext.quoteMessage = await toMessageExt(msg.quoteElem!.quoteMessage!, secretKey);
            }
            ext.data = list;
          }
          break;
        case MessageType.card:
          var data = json.decode(msg.textElem?.content ?? '{}');
          ext.data = data;
          break;
        case MessageType.location:
          var data = json.decode(msg.locationElem?.description ?? '{}');
          ext.data = data;
          break;
        case MessageType.custom:
          var data = json.decode(msg.customElem?.data ?? '{}');
          ext.data = data;
          ext.isVoice = [
            SignalingType.CustomSignalingAcceptType,
            SignalingType.CustomSignalingAwaitType,
            SignalingType.CustomSignalingCallType,
            SignalingType.CustomSignalingCancelType,
            SignalingType.CustomSignalingHungUpType,
            SignalingType.CustomSignalingInviteType,
            SignalingType.CustomSignalingIsBusyType,
            SignalingType.CustomSignalingRejectType,
            SignalingType.CustomSignalingTimeoutType
          ].contains(data['contentType']);
          ext.isRedEnvelope = [81, 82, 83].contains(data['contentType']);
          ext.isBothDelete = [27].contains(data['contentType']);
          ext.isGroupBothDelete = [77].contains(data['contentType']);
          break;

        case MessageType.groupMemberMutedNotification:
        case MessageType.groupMemberCancelMutedNotification:
        case MessageType.memberInvitedNotification:
        case MessageType.groupInfoSetNotification:
        case MessageType.memberEnterNotification:
        case MessageType.memberKickedNotification:
        case MessageType.groupCreatedNotification:
        case MessageType.burnAfterReadingNotification:
        case MessageType.memberQuitNotification:
          var data = json.decode(msg.notificationElem?.detail ?? '{}');
          ext.data = data;
          ext.isSnapchat = data['isPrivate'] ?? false;
          break;
        case MessageType.picture:
          ext.secretKey = _getSecretKey(msg, secretKey);
          var (width, height) = _computedSize(width: msg.pictureElem?.sourcePicture?.width?.toDouble(), height: msg.pictureElem?.sourcePicture?.height?.toDouble());
          ext.width = width;
          ext.height = height;

          break;
        case 300:
          Map<String, dynamic> map = jsonDecode(msg.textElem?.content ?? '{}');
          ext.data = jsonDecode(map['data'] ?? '{}');

          /// 获取文件名
          String fileName = (ext.data['url'] as String).split('/').last;

          /// 优先判断本地文件
          String? filePath = '${ImCore.dirPath}/emoji/${ext.data['emoticons_id']}/$fileName';
          if (File(filePath).existsSync()) {
            ext.file = File(filePath);
          }
          ext.secretKey = _getSecretKey(msg, secretKey);
          var (width, height) = _computedSize(width: map['w'] ?? 120, height: map['h'] ?? 120);
          ext.width = width;
          ext.height = height;
          break;
        case MessageType.video:
          ext.secretKey = _getSecretKey(msg, secretKey);
          var (width, height) = _computedSize(width: msg.videoElem?.snapshotWidth?.toDouble(), height: msg.videoElem?.snapshotHeight?.toDouble());
          ext.width = width;
          ext.height = height;
          break;
        default:
      }

      return MessageExt(ext: ext, m: msg);
    } catch (e) {
      debugPrint(e.toString());
      return MessageExt(ext: ext, m: msg);
    }
  }
}
