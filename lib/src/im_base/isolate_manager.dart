part of im_kit;
/*
 * Summary: isolate_manager
 * Created Date: 2023-06-21 14:44:02
 * Author: Spicely
 * -----
 * Last Modified: 2023-08-01 17:19:58
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
  }
}

class IsolateManager {
  static bool _isInit = false;

  static final ObserverList<ImDownloadListen> _listeners = ObserverList<ImDownloadListen>();

  static final List<String> _downloadIds = [];

  static void addListener(ImDownloadListen listener) {
    _listeners.add(listener);
  }

  static void removeListener(ImDownloadListen listener) {
    _listeners.remove(listener);
  }

  /// openIm 通信端口
  static late final SendPort _isolateSendPort;

  /// 初始化
  static Future<void> init(String dirPath) async {
    if (_isInit) return;
    ImCore.dirPath = dirPath;
    _isInit = true;
    IsolateTask task = await Utils.createIsolate('muka_isolate', null, _isolateEntry);

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
  static Future<void> downloadFile(Message message) async {
    if (_downloadIds.contains(message.clientMsgID!)) return;
    _downloadIds.add(message.clientMsgID!);
    String url = message.fileElem?.sourceUrl ??
        message.soundElem?.sourceUrl ??
        message.pictureElem?.sourcePicture?.url ??
        message.videoElem?.videoUrl ??
        '';
    String savaPath = ImCore.getSavePath(message);

    /// 检查文件是否存在
    File file = File(savaPath);
    if (file.existsSync()) {
      _downloadIds.remove(message.clientMsgID!);
      for (ImDownloadListen listener in _listeners) {
        listener.onDownloadSuccess(message.clientMsgID!, savaPath);
      }
      return;
    }
    ReceivePort port = ReceivePort();
    _isolateSendPort.send(_PortModel(
      method: _PortMethod.downloadFile,
      data: {'url': url, 'savePath': savaPath},
      sendPort: port.sendPort,
    ));
    port.listen((msg) {
      if (msg is PortProgress) {
        for (ImDownloadListen listener in _listeners) {
          listener.onDownloadProgress(message.clientMsgID!, msg.progress);
        }
      }
      if (msg is PortResult) {
        _downloadIds.remove(message.clientMsgID!);
        if (msg.data != null) {
          for (ImDownloadListen listener in _listeners) {
            listener.onDownloadSuccess(message.clientMsgID!, msg.data);
          }
        } else {
          for (ImDownloadListen listener in _listeners) {
            listener.onDownloadSuccess(message.clientMsgID!, msg.error!);
          }
        }
        port.close();
      }
    });
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
          }
        } catch (e) {
          msg.sendPort?.send(PortResult(error: e.toString()));
        }
      }
    });
  }
}
