part of im_kit;
/*
 * Summary: isolate_manager
 * Created Date: 2023-06-21 14:44:02
 * Author: Spicely
 * -----
 * Last Modified: 2023-09-06 18:31:28
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
  /// 下载文件
  downloadFile,

  /// 对文件加密
  encryptImage,

  /// 解密文件
  decryptFile,

  /// 获取图片信息
  getImageInfo,
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
  _PortMethod method;

  dynamic data;

  SendPort? sendPort;

  String? error;

  _PortModel({
    required this.method,
    this.data,
    this.sendPort,
    this.error,
  });

  _PortModel.fromJson(Map<String, dynamic> json) : method = json['method'] {
    data = json['data'];
    error = json['error'];
  }
}

class ImKitIsolateManager {
  static bool _isInit = false;

  static final ObserverList<ImKitListen> _listeners = ObserverList<ImKitListen>();

  static final List<String> _downloadIds = [];

  static void addListener(ImKitListen listener) {
    _listeners.add(listener);
  }

  static void removeListener(ImKitListen listener) {
    _listeners.remove(listener);
  }

  /// openIm 通信端口
  static late final SendPort _isolateSendPort;

  /// 初始化
  static Future<void> init(String dirPath, {String? privateKeyPath, String? publicKeyPath}) async {
    if (_isInit) return;
    ImCore.dirPath = dirPath;
    _isInit = true;
    IsolateTask task = await Utils.createIsolate(
      'imKitIsolate',
      null,
      _isolateEntry,
    );

    task.receivePort.listen((msg) {
      if (msg is _PortModel) {
        switch (msg.method) {
          case _PortMethod.downloadFile:
            // IsolateMethod.downloadFile(msg);
            break;
          default:
        }
      }
      if (msg is SendPort) {
        _isolateSendPort = msg;
      }
    });
  }

  /// 下载压缩包
  ///
  /// [url] 下载地址
  static void downloadFile(Message message) {
    if (_downloadIds.contains(message.clientMsgID!)) return;
    _downloadIds.add(message.clientMsgID!);
    String url = message.fileElem?.sourceUrl ??
        message.soundElem?.sourceUrl ??
        message.pictureElem?.sourcePicture?.url ??
        message.videoElem?.videoUrl ??
        '';
    String savePath = ImCore.getSavePath(message);

    /// 检查文件是否存在
    File file = File(savePath);
    if (file.existsSync()) {
      _downloadIds.remove(message.clientMsgID!);
      for (ImKitListen listener in _listeners) {
        listener.onDownloadSuccess(message.clientMsgID!, savePath);
      }
      return;
    }
    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.downloadFile,
      data: {'url': url, 'savePath': savePath},
      sendPort: port.sendPort,
    ));
    port.listen((msg) {
      if (msg is PortProgress) {
        for (ImKitListen listener in _listeners) {
          listener.onDownloadProgress(message.clientMsgID!, msg.progress);
        }
      }
      if (msg is PortResult) {
        _downloadIds.remove(message.clientMsgID!);
        if (msg.data != null) {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadSuccess(message.clientMsgID!, msg.data);
          }
        } else {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadFailure(message.clientMsgID!, msg.error!);
          }
        }
        port.close();
      }
    });
  }

  /// 获取图片信息
  static Future<(String, String, int, int)> getImageInfo(String path) {
    var completer = Completer<(String, String, int, int)>();
    String savePath = ImCore.getSavePathForFilePath(path);

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(method: _PortMethod.getImageInfo, data: {'path': path}, sendPort: port.sendPort));

    port.listen((msg) {
      if (msg is PortResult<(String, int, int)>) {
        if (msg.data != null) {
          completer.complete((savePath, msg.data!.$1, msg.data!.$2, msg.data!.$3));
        } else {
          completer.completeError(msg.error!);
        }
        port.close();
      }
    });
    return completer.future;
  }

  /// 加密文件
  ///
  /// 返回值 (路径,类型,宽,高)
  static Future<void> encryptImage(String key, String iv, String path) async {
    var completer = Completer();
    String savePath = ImCore.getSavePathForFilePath(path);

    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.encryptImage,
      data: {'key': key, 'iv': iv, 'filePath': path, 'savePath': savePath},
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

  /// 解密文件
  static Future<String> decryptFile(String key, String iv, String path) async {
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

  static Future<void> _isolateEntry(IsolateTaskData task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }
    final receivePort = ReceivePort();
    task.sendPort.send(receivePort.sendPort);

    receivePort.listen((msg) async {
      if (msg is _PortModel) {
        try {
          switch (msg.method) {
            case _PortMethod.downloadFile:
              IsolateMethod.downloadFile(msg);
              break;
            case _PortMethod.encryptImage:
              IsolateMethod.encryptImage(msg);
            case _PortMethod.decryptFile:
              IsolateMethod.decryptFile(msg);
            case _PortMethod.getImageInfo:
              IsolateMethod.getImageInfo(msg);
          }
        } catch (e) {
          msg.sendPort?.send(PortResult(error: e.toString()));
        }
      }
    });
  }
}
