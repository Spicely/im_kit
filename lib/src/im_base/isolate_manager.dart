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

  /// 转成MessageExt
  toMessageExt,

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

  /// Uint8List保存到临时文件夹
  static Future<String> saveBytesToTemp(Uint8List pngBytes) async {
    Completer<String> completer = Completer<String>();
    String path = join(ImCore.tempPath, '${const Uuid().v4()}.png');
    File file = File(path);
    await file.writeAsBytes(pngBytes);
    completer.complete(path);
    return completer.future;
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
  static Future<String> copyFile(String path, String savePath) {
    var completer = Completer<String>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.copyFile,
      data: {'path': path, 'savePath': savePath},
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
  static Future<MessageExt> toMessageExt(String uid, Message msg) async {
    var completer = Completer<MessageExt>();

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.toMessageExt,
      data: {'msg': msg, 'uid': uid},
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
            case _PortMethod.toMessageExt:
              IsolateMethod.toMessageExt(msg);
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
}
