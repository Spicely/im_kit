part of im_kit;
/*
 * Summary: isolate_manager
 * Created Date: 2023-06-21 14:44:02
 * Author: Spicely
 * -----
 * Last Modified: 2023-09-08 11:15:43
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

enum _PortMethod {
  // /// 下载多文件
  // downloadFiles,

  /// 复制文件
  copyFile,

  downEmoji,
  checkEmoji,

  /// 将saveBytes保存为文件
  saveBytes,
}

/// 下载进度
class PortProgress {
  final double progress;

  PortProgress(this.progress);
}

class PortResult<T> {
  final T? data;

  final String? error;

  PortResult({
    this.data,
    this.error,
  });

  T get value {
    if (error != null) {
      throw error!;
    }
    return data!;
  }
}

class _PortModel {
  final _PortMethod method;

  final dynamic data;

  final SendPort? sendPort;

  final String? error;

  _PortModel({
    required this.method,
    this.data,
    this.sendPort,
    this.error,
  });

  factory _PortModel.fromJson(Map<String, dynamic> json) {
    return _PortModel(
      method: _PortMethod.values[json['method']],
      data: json['data'],
      sendPort: json['sendPort'],
      error: json['error'],
    );
  }
}

class DownloadItem {
  final String path;
  final String url;
  final String secretKey;
  final String savePath;

  DownloadItem({
    required this.path,
    required this.url,
    required this.secretKey,
    required this.savePath,
  });
}

class ImKitIsolateManager {
  static bool _isInit = false;

  static final ObserverList<ImKitListen> _listeners = ObserverList<ImKitListen>();

  static void addListener(ImKitListen listener) {
    _listeners.add(listener);
  }

  static void removeListener(ImKitListen listener) {
    _listeners.remove(listener);
  }

  /// openIm 通信端口
  static late final SendPort _isolateSendPort;

  static Future<bool> saveFileToAlbumByU8List(Uint8List pngBytes, String name, {String androidRelativePath = 'Pictures'}) async {
    try {
      await ImageGallerySaver.saveImage(pngBytes, name: name, isReturnImagePathOfIOS: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Uint8List保存到临时文件夹
  static Future<String> saveBytesToTemp(Uint8List bytes) async {
    var completer = Completer<String>();

    ReceivePort port = ReceivePort();

    _isolateSendPort.send(_PortModel(
      method: _PortMethod.saveBytes,
      data: {'path': join(ImCore.tempPath, '${const Uuid().v4()}.jpeg'), 'bytes': bytes},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult<String>) {
        if (msg.data != null) {
          completer.complete(msg.data);
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 保存文件到相册
  static Future<bool> saveFileToAlbum(String path, {String? fileName}) async {
    try {
      if (Utils.isMobile) {
        await ImageGallerySaver.saveFile(path);
      } else {
        String? saveDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: '保存文件',
          lockParentWindow: true,
        );
        if (saveDir != null) {
          ImKitIsolateManager.copyFile(path, saveDir, fileName: fileName);
        } else {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 获取本地文件
  static Future<List<File>> getLocFile(String conversationID, Message message) async {
    String dirPath = join(ImCore.dirPath, OpenIM.iMManager.uid, 'dec', conversationID);
    switch (message.contentType) {
      case MessageType.picture:
      case MessageType.voice:
      case MessageType.file:
        {
          String? url = message.pictureElem?.sourcePicture?.url ?? message.soundElem?.sourceUrl ?? message.fileElem?.sourceUrl;
          if (url == null) {
            return [File(Utils.getValue(message.pictureElem?.sourcePath ?? message.soundElem?.soundPath ?? message.fileElem?.filePath, ''))];
          }

          /// 获取文件名
          String filename = url.split('/').last;
          File file = File(join(dirPath, filename));
          bool status = await file.exists();
          if (status) {
            return [file];
          }
          return [];
        }
      case MessageType.video:
        {
          String? snapUrl = message.videoElem?.snapshotUrl;
          String? videoUrl = message.videoElem?.videoUrl;
          if (snapUrl == null || videoUrl == null) {
            return [File(Utils.getValue(message.videoElem?.snapshotPath, '')), File(Utils.getValue(message.videoElem?.videoPath, ''))];
          }

          /// 获取文件名
          File snapFile = File(join(dirPath, snapUrl.split('/').last));
          File videoFile = File(join(dirPath, videoUrl.split('/').last));
          if (await snapFile.exists() && await videoFile.exists()) {
            return [snapFile, videoFile];
          }
          return [];
        }
      default:
        return [];
    }
  }

  /// 初始化
  static Future<void> init(String dirPath) async {
    if (_isInit) return;
    MediaKit.ensureInitialized();
    ImCore.init(dirPath);
    _isInit = true;
    IsolateTask task = await Utils.createIsolate('imKitIsolate', {'dirPath': dirPath}, _isolateEntry);

    task.receivePort.listen((msg) {
      if (msg is SendPort) {
        _isolateSendPort = msg;
      }
    });
  }

  // /// 下载多文件
  // static void downloadFiles(String id, List<DownloadItem> data) {
  //   ReceivePort port = ReceivePort();
  //   _isolateSendPort.send(_PortModel(method: _PortMethod.downloadFiles, data: {'id': id, 'data': data}, sendPort: port.sendPort));
  //   port.listen((msg) {
  //     if (msg is PortProgress) {
  //       for (ImKitListen listener in _listeners) {
  //         listener.onDownloadProgress(id, msg.progress);
  //       }
  //     } else {
  //       if (msg is PortResult) {
  //         if (msg.data != null) {
  //           for (ImKitListen listener in _listeners) {
  //             listener.onDownloadSuccess(id, msg.data!);
  //           }
  //         } else {
  //           for (ImKitListen listener in _listeners) {
  //             listener.onDownloadFailure(id, msg.error!);
  //           }
  //         }
  //       }
  //       port.close();
  //     }
  //   });
  // }

  /// 下载压缩包
  ///
  /// [url] 下载地址
  ///
  /// [path] 保存路径
  ///
  /// [id] 表情包id
  static Future<List<EmojiItemModel>> downEmoji(String id, String url, String path) async {
    var completer = Completer<List<EmojiItemModel>>();
    final port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.downEmoji,
      data: {'url': url, 'path': path, 'id': id},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortProgress) {
        for (ImKitListen listener in _listeners) {
          listener.onDownloadProgress(id, msg.progress);
        }
      } else if (msg is PortResult<List<EmojiItemModel>>) {
        if (msg.data != null) {
          completer.complete(msg.data);
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 复制文件
  static Future<String> copyFile(String path, String saveDir, {String? fileName}) {
    var completer = Completer<String>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.copyFile,
      data: {'path': path, 'saveDir': saveDir, 'fileName': fileName},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult<String>) {
        if (msg.data != null) {
          completer.complete(msg.data);
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 转成MessageExt
  static Future<MessageExt> toMessageExt(Message msg) async {
    Completer<MessageExt> completer = Completer<MessageExt>();

    final ext = ImExtModel(key: GlobalKey(), createTime: DateTime.now());

    if (msg.sendTime != null) {
      ext.time = msg.sendTime!.formatDate();
    }

    /// 阅后即焚
    ext.isPrivateChat = msg.attachedInfoElem?.isPrivateChat ?? false;
    try {
      switch (msg.contentType) {
        case MessageType.at_text:
        case MessageType.text:
        case MessageType.quote:
          {
            String v = msg.atElem?.text ?? msg.atElem?.text ?? msg.quoteElem?.text ?? msg.content ?? '';
            ext.data = v;
            if (msg.contentType == MessageType.quote || (msg.contentType == MessageType.at_text && msg.atElem?.quoteMessage != null)) {
              Message? quoteMsg = msg.quoteElem?.quoteMessage ?? msg.atElem?.quoteMessage;
              if (quoteMsg != null) {
                ext.quoteMessage = await toMessageExt(quoteMsg);
              }
            }

            // List<AtUserInfo> atUsersInfo = msg.atElem?.atUsersInfo ?? [];

            // List<ImAtTextType> list = [];

            // /// 匹配艾特用户
            // String atReg = atUsersInfo.map((v) => '@${v.atUserID}#${v.groupNickname} ').join('|');
            // var regexEmoji = ImCore.emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

            // /// 匹配电话号码
            // String phoneReg = r"\b\d{5,}\b";

            // /// 匹配网址
            // String urlRge = r'(((http(s)?:\/\/(www\.)?)|(www\.))([-a-zA-Z0-9@:;_\+.%#?&\/=]*))|([-a-zA-Z@:;_\+.%#?&\/=]{2,}\.((com)|(cn)))/g';

            // /// 匹配邮箱
            // String email = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";

            // String regExp;
            // if (atUsersInfo.isEmpty) {
            //   regExp = [regexEmoji, urlRge, phoneReg, email].join('|');
            // } else {
            //   regExp = [regexEmoji, urlRge, atReg, phoneReg, email].join('|');
            // }
            // v.splitMapJoin(
            //   RegExp('($regExp)'),
            //   onMatch: (Match m) {
            //     String value = m.group(0)!;
            //     if (RegExp(regexEmoji).hasMatch(value)) {
            //       String emoji = ImCore.emojiFaces[value]!;
            //       list.add(ImAtTextType(type: ImAtType.emoji, text: emoji));
            //     } else if (RegExp(email).hasMatch(value)) {
            //       list.add(ImAtTextType(type: ImAtType.email, text: value));
            //     } else if (RegExp(atReg).hasMatch(value) && atUsersInfo.isNotEmpty) {
            //       String id = value.split('#').first.replaceFirst('@', '').trim();

            //       AtUserInfo? atUserInfo = atUsersInfo.firstWhereOrNull((v) => v.atUserID == id);
            //       if (atUserInfo == null) {
            //         if (RegExp(phoneReg).hasMatch(value)) {
            //           list.add(ImAtTextType(type: ImAtType.phone, text: value));
            //         } else {
            //           list.add(ImAtTextType(type: ImAtType.text, text: value));
            //         }
            //       } else {
            //         if (atUserInfo.atUserID == OpenIM.iMManager.uid) {
            //           list.add(ImAtTextType(type: ImAtType.at, text: '@你 ', userInfo: atUserInfo));
            //         } else {
            //           list.add(ImAtTextType(type: ImAtType.at, text: '@${atUserInfo.groupNickname} ', userInfo: atUserInfo));
            //         }
            //       }
            //     } else if (RegExp(urlRge).hasMatch(value)) {
            //       list.add(ImAtTextType(type: ImAtType.url, text: value));
            //     } else if (RegExp(phoneReg).hasMatch(value)) {
            //       list.add(ImAtTextType(type: ImAtType.phone, text: value));
            //     }
            //     return '';
            //   },
            //   onNonMatch: (String n) {
            //     list.add(ImAtTextType(type: ImAtType.text, text: n));
            //     return '';
            //   },
            // );

            // ext.data = list;
          }
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
          ext.isBothDelete = [27, 77].contains(data['contentType']);
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
        case MessageType.oaNotification:
        case MessageType.groupOwnerTransferredNotification:
          var data = json.decode(msg.notificationElem?.detail ?? '{}');
          ext.data = data;
          ext.isSnapchat = data['isPrivate'] ?? false;
          break;
        case MessageType.picture:
          var (width, height) = _computedSize(width: msg.pictureElem?.sourcePicture?.width?.toDouble(), height: msg.pictureElem?.sourcePicture?.height?.toDouble());
          ext.width = width;
          ext.height = height;

          break;
        case 300:
          Map<String, dynamic> map = jsonDecode(msg.content ?? '{}');
          ext.data = jsonDecode(map['data'] ?? '{}');

          /// 获取文件名
          String fileName = (ext.data['url'] as String).split('/').last;

          /// 优先判断本地文件
          String? filePath = '${ImCore.dirPath}/emoji/${ext.data['emoticons_id']}/$fileName';
          if (File(filePath).existsSync()) {
            ext.file = File(filePath);
          }
          var (width, height) = _computedSize(width: map['w'] ?? 120, height: map['h'] ?? 120);
          ext.width = width;
          ext.height = height;
          break;
        case MessageType.video:
          var (width, height) = _computedSize(width: msg.videoElem?.snapshotWidth?.toDouble(), height: msg.videoElem?.snapshotHeight?.toDouble());
          ext.width = width;
          ext.height = height;
          break;
        default:
          var data = json.decode(msg.content ?? '{}');
          ext.data = data;
      }

      completer.complete(MessageExt(ext: ext, m: msg));
    } catch (e) {
      debugPrint(e.toString());
      completer.complete(MessageExt(ext: ext, m: msg));
    }
    return completer.future;
  }

  static Future<void> _isolateEntry(IsolateTaskData task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }
    Map<String, dynamic> data = task.data;
    ImCore.dirPath = data['dirPath'];
    final receivePort = ReceivePort();
    task.sendPort.send(receivePort.sendPort);

    receivePort.listen((msg) async {
      if (msg is _PortModel) {
        try {
          switch (msg.method) {
            // case _PortMethod.downloadFiles:
            //   IsolateMethod.downloadFiles(msg);
            //   break;
            case _PortMethod.downEmoji:
              IsolateMethod.downEmoji(msg);
              break;
            case _PortMethod.checkEmoji:
              IsolateMethod.checkEmoji(msg);
              break;

            case _PortMethod.copyFile:
              IsolateMethod.copyFile(msg);
              break;
            case _PortMethod.saveBytes:
              IsolateMethod.saveImageByUint8List(msg);
              break;
          }
        } catch (e) {
          msg.sendPort?.send(PortResult(error: e.toString()));
        }
      }
    });
  }

  /// 检测表情包是否下载
  ///
  /// [url] 下载地址
  ///
  /// [path] 保存路径
  ///
  /// [id] 表情包id
  static Future<List<EmojiItemModel>> checkEmoji(String url, String path, String id) async {
    var completer = Completer<List<EmojiItemModel>>();
    final port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.checkEmoji,
      data: {'url': url, 'path': path, 'id': id},
      sendPort: port.sendPort,
    ));
    port.listen((msg) {
      if (msg is PortResult<List<EmojiItemModel>>) {
        if (msg.data != null) {
          completer.complete(msg.data);
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 全局删除消息群聊清楚消息
  static _cleanPrivateChatAll() async {
    try {
      SearchResult result = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: null, // 根据会话查询，如果是全局搜索传null
        messageTypeList: [MessageType.custom], // 消息类型列表
        searchTimePosition: 0, // 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
        searchTimePeriod: 0, // 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天
        pageIndex: 1, // 当前页数
        count: 9999999999999, // 每页数量
      );
      if (result.searchResultItems == null || result.searchResultItems!.isEmpty) return;

      for (var result in result.searchResultItems!) {
        if (result.messageCount != 0) {
          List<MessageExt> exts = await Future.wait((result.messageList ?? []).map((e) => e.toExt()).toList());
          int index = exts.indexWhere((v) => v.ext.isBothDelete);
          if (index != -1) {
            OpenIM.iMManager.conversationManager.getMultipleConversation(
              conversationIDList: [result.conversationID ?? ''], // 会话ID集合
            ).then((conversation) {
              OpenIM.iMManager.messageManager
                  .getHistoryMessageList(
                userID: Utils.getValue(conversation.first.userID, null), // 单聊对象的userID
                groupID: Utils.getValue(conversation.first.groupID, null), // 群聊的组id
                startMsg: result.messageList?[index], // 消息体
                count: 999999999999999, // 每次拉取的数量
              )
                  .then((list) {
                if (list.isEmpty) return;
                for (var element in list) {
                  OpenIM.iMManager.messageManager.deleteMessageFromLocalStorage(message: element);
                }
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
