// ignore_for_file: library_private_types_in_public_api

part of im_kit;

class IsolateMethod {
  /// 下载文件
  static Future<void> downloadFile(_PortModel params) async {
    try {
      String url = params.data['url'];
      String savePath = params.data['savePath'];

      await Dio().download(url, savePath, onReceiveProgress: (count, total) {
        params.sendPort?.send(PortProgress(count / total));
      });
      params.sendPort?.send(PortResult(data: savePath));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }
}
