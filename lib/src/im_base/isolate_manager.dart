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

  /// 获取图片信息
  getImageInfo,

  /// 复制文件
  copyFile,
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
  static Future<void> init(String dirPath) async {
    if (_isInit) return;
    ImCore.dirPath = dirPath;
    _isInit = true;
    IsolateTask task = await Utils.createIsolate(
      'imKitIsolate',
      null,
      _isolateEntry,
    );

    task.receivePort.listen((msg) {
      if (msg is SendPort) {
        _isolateSendPort = msg;
      }
    });
  }

  /// 下载多文件
  static void downloadFiles(String id, List<String> urls) {
    if (_downloadIds.contains(id)) return;

    /// 获取保存路径
    List<Map<String, String>> list = [];
    for (var v in urls) {
      list.add({'url': v, 'savePath': ImCore.getSavePathForFilePath(v)});
    }
    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(method: _PortMethod.downloadFiles, data: list, sendPort: port.sendPort));
    port.listen((msg) {
      if (msg is PortProgress) {
        for (ImKitListen listener in _listeners) {
          listener.onDownloadProgress(id, msg.progress);
        }
      }
      if (msg is PortResult<List<String>>) {
        _downloadIds.remove(id);
        if (msg.data != null) {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadSuccess(id, msg.data!);
          }
        } else {
          for (ImKitListen listener in _listeners) {
            listener.onDownloadFailure(id, msg.error!);
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

  /// 复制文件
  static Future<String> copyFile(String path) {
    var completer = Completer<String>();
    String savePath = ImCore.getSavePathForFilePath(path);

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
      await file.rename(ImCore.getSavePathForFilePath(url));
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
            case _PortMethod.downloadFiles:
              IsolateMethod.downloadFiles(msg);
              break;
            case _PortMethod.encryptFile:
              IsolateMethod.encryptFile(msg);
            case _PortMethod.decryptFile:
              IsolateMethod.decryptFile(msg);
            case _PortMethod.getImageInfo:
              IsolateMethod.getImageInfo(msg);
            case _PortMethod.copyFile:
              IsolateMethod.copyFile(msg);
          }
        } catch (e) {
          msg.sendPort?.send(PortResult(error: e.toString()));
        }
      }
    });
  }
}
