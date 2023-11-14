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
  /// 下载多文件
  downloadFiles,

  /// 对文件加密
  encryptFile,

  /// 解密文件
  decryptFile,

  /// 复制文件
  copyFile,

  /// 将Uint8List保存成图片
  saveImageByUint8List,

  /// 转成MessageExt
  toMessageExt,

  /// 上传文件
  uploadFile,

  /// 复制文件为下载文件
  copyFileToDownload,

  downEmoji,
  checkEmoji,
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

  /// 保存文件到相册
  static Future<bool> saveFileToAlbum(String path) async {
    try {
      await ImageGallerySaver.saveFile(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  ///保存文件
  static File writeFileByU8Async(String path, Uint8List data) {
    File file = File(path);
    file.writeAsBytesSync(data, flush: true);
    return file;
  }

  static Uint8List decFileNoPath({
    required String keyStr,
    required Uint8List fileByte,
  }) {
    DecDataRes res2 = DecDataRes.fromByUint8list(fileByte, keyStr, decIV: IV.fromUtf8("abcd1234abcd1234"));
    if (res2.isEncData == 0) return fileByte;
    Uint8List decData = res2.decFile;
    return decData;
  }

  /// 初始化
  static Future<void> init(String dirPath) async {
    if (_isInit) return;
    // MediaKit.ensureInitialized();
    ImCore.dirPath = dirPath;
    _isInit = true;
    IsolateTask task = await Utils.createIsolate(
      'imKitIsolate',
      {'dirPath': dirPath},
      _isolateEntry,
    );

    task.receivePort.listen((msg) {
      if (msg is SendPort) {
        _isolateSendPort = msg;
      }
    });
  }

  /// 下载多文件
  static void downloadFiles(String id, List<DownloadItem> data) {
    /// 获取保存路径
    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(method: _PortMethod.downloadFiles, data: {'id': id, 'data': data}, sendPort: port.sendPort));
    port.listen((msg) {
      if (msg is PortProgress) {
        for (ImKitListen listener in _listeners) {
          listener.onDownloadProgress(id, msg.progress);
        }
      } else {
        if (msg.data != null) {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadSuccess(id, (msg as PortResult).data!);
          }
        } else {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadFailure(id, (msg as PortResult).error!);
          }
        }
        port.close();
      }
    });
  }

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
  static Future<String> copyFile(String path) {
    var completer = Completer<String>();
    var savePath = ImCore.getSavePathForFilePath(path);

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.copyFile,
      data: {'path': path, 'savePath': savePath.$1, 'desPath': savePath.$2},
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

  /// 复制为下载文件
  static Future<void> copyFileToDownload(MessageExt extMsg) {
    String? filePath;
    String? savePath;
    if ([MessageType.picture, MessageType.voice, MessageType.file, MessageType.video].contains(extMsg.m.contentType)) {
      filePath = extMsg.m.pictureElem?.sourcePath ?? extMsg.m.videoElem?.videoPath ?? extMsg.m.fileElem?.filePath ?? extMsg.m.soundElem?.soundPath;
      savePath = ImCore.getSavePath(extMsg.m);
    }
    if (filePath == null || savePath == null) return Future.value();
    var completer = Completer<void>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.copyFileToDownload,
      data: {'path': filePath, 'savePath': savePath},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult<String>) {
        if (msg.data != null) {
          completer.complete();
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 加密文件
  static Future<void> encryptFile(String key, String path, {String iv = 'abcd1234abcd1234'}) async {
    var completer = Completer();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.encryptFile,
      data: {'key': key, 'iv': iv, 'path': path},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult) {
        if (msg.data != null) {
          completer.complete();
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 重命名文件
  static Future<void> renameFile(String path, String url) async {
    /// 检查文件是否存在  如果存在则重命名
    File file = File(path);
    if (await file.exists()) {
      await file.rename(ImCore.getSaveForUrlPath(url));
    }
  }

  /// 解密文件
  static Future<String> decryptFile(String key, String path, {String iv = 'abcd1234abcd1234'}) async {
    var completer = Completer<String>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.decryptFile,
      data: {'key': key, 'iv': iv, 'filePath': path},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult) {
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
  static Future<MessageExt> toMessageExt(String uid, Message msg, String secretKey) async {
    var completer = Completer<MessageExt>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.toMessageExt,
      data: {'msg': msg, 'secretKey': secretKey, 'uid': uid},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult) {
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
            case _PortMethod.downloadFiles:
              IsolateMethod.downloadFiles(msg);
              break;
            case _PortMethod.downEmoji:
              IsolateMethod.downEmoji(msg);
              break;
            case _PortMethod.checkEmoji:
              IsolateMethod.checkEmoji(msg);
              break;
            case _PortMethod.encryptFile:
              IsolateMethod.encryptFile(msg);
            case _PortMethod.decryptFile:
              IsolateMethod.decryptFile(msg);
            case _PortMethod.copyFile:
              IsolateMethod.copyFile(msg);
            case _PortMethod.saveImageByUint8List:
              IsolateMethod.saveImageByUint8List(msg);
            case _PortMethod.toMessageExt:
              IsolateMethod.toMessageExt(msg);
            case _PortMethod.uploadFile:
              IsolateMethod.uploadFile(msg);
            case _PortMethod.copyFileToDownload:
              IsolateMethod.copyFileToDownload(msg);
          }
        } catch (e) {
          msg.sendPort?.send(PortResult(error: e.toString()));
        }
      }
    });
  }

  /// 将Uint8List存储为图片
  static Future<String> saveImageByUint8List(Uint8List bytes) async {
    var completer = Completer<String>();

    String path = join(ImCore.saveDir, '${const Uuid().v4()}.jpg');

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.saveImageByUint8List,
      data: {'filePath': path, 'uint8List': bytes},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult) {
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

  /// 上传文件
  static Future<String> uploadFile(String path, String token, String hostUrl) async {
    var completer = Completer<String>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.uploadFile,
      data: {'filePath': path, 'token': token, 'hostUrl': hostUrl},
      sendPort: port.sendPort,
    ));

    port.listen((msg) {
      if (msg is PortResult) {
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
}
