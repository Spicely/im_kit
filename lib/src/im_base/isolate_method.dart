// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, deprecated_export_use

part of im_kit;

// ignore: constant_identifier_names
const ROADOM_STR = "bwGO8X5gdaM5dsV@";

class IsolateMethod {
  // /// 下载多文件
  // static Future<void> downloadFiles(_PortModel params) async {
  //   try {
  //     Map<String, dynamic> progressMap = {};
  //     List<DownloadItem> items = params.data['data'];
  //     String id = params.data['id'];

  //     /// 先判断本地文件是否存在
  //     bool status = items.every((v) => File(v.path).existsSync());
  //     if (status) {
  //       params.sendPort?.send(PortResult(data: items.map((e) => e.path).toList()));
  //       return;
  //     }

  //     /// 判断下载文件是否存在
  //     status = items.every((v) => File(v.savePath).existsSync());
  //     if (status) {
  //       params.sendPort?.send(PortResult(data: items.map((e) => e.savePath).toList()));
  //       return;
  //     }

  //     await Future.wait(items.map((e) {
  //       progressMap[id] = {'count': 0, 'total': 0};
  //       return e.url.isEmpty
  //           ? Future.value('')
  //           : Dio().get(
  //               e.url,
  //               options: Options(responseType: ResponseType.bytes),
  //               onReceiveProgress: (count, total) {
  //                 progressMap[id] = {'count': count, 'total': total};
  //                 double progress = 0;
  //                 progressMap.forEach((key, value) {
  //                   if (value['total'] == 0) return;
  //                   progress += value['count'] / value['total'];
  //                 });
  //                 params.sendPort?.send(PortProgress(progress / progressMap.length));
  //               },
  //             ).then((res) {
  //               Uint8List u = Uint8List.fromList(res.data);
  //               if (e.savePath.isNotEmpty) {
  //                 ImKitIsolateManager.writeFileByU8Async(e.savePath, ImKitIsolateManager.decFileNoPath(keyStr: e.secretKey, fileByte: u));
  //               }
  //             }).catchError((e) {
  //               throw e;
  //             });
  //     }).toList());
  //     progressMap.remove(id);
  //     params.sendPort?.send(PortResult(data: items.map((e) => e.savePath).toList()));
  //   } catch (e) {
  //     params.sendPort?.send(PortResult(error: e.toString()));
  //   }
  // }

  /// 复制文件
  static void copyFile(_PortModel params) async {
    String path = params.data['path'];
    String savePath = params.data['savePath'];
    try {
      await File(path).copy(savePath);
      params.sendPort?.send(PortResult(data: savePath));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  /// 复制文件
  static void saveImageByUint8List(_PortModel params) async {
    String path = params.data['filePath'];
    Uint8List bytes = params.data['uint8List'];
    try {
      await File(path).writeAsBytes(bytes, flush: true);
      params.sendPort?.send(PortResult(data: path));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  /// 下载表情包
  static downEmoji(_PortModel params) async {
    try {
      final data = params.data;
      final url = data['url'];
      final path = data['path'];
      final id = data['id'];
      String fileName = url.substring(url.lastIndexOf('/') + 1, url.length);
      String savePath = '${ImCore.dirPath}/$path';
      await Dio().download(url, '$savePath/$fileName');
      String jsonStr = File('$savePath/$fileName').readAsStringSync();

      /// 读取json内容
      final emojiList = json.decode(jsonStr);

      Map<String, dynamic> progressMap = {};

      List<EmojiItemModel> dataList = (emojiList['dataList'] as List).map((e) => EmojiItemModel.fromJson(e)).toList();

      /// 检测文件是否存在
      dataList.removeWhere((v) {
        if (File('$savePath/${v.name}').existsSync()) {
          return true;
        }
        return false;
      });

      await Future.wait(dataList.map((e) {
        progressMap[e.name] = {'count': 0, 'total': 0};
        return Dio().download(
          'https://feiyin-face-file.oss-cn-hangzhou.aliyuncs.com/emoticons/$id/${e.name}',
          '$savePath/${e.name}',
          onReceiveProgress: (int count, int total) {
            progressMap[e.name] = {'count': count, 'total': total};
            double progress = 0;
            progressMap.forEach((key, value) {
              if (value['total'] == 0) return;
              progress += value['count'] / value['total'];
            });
            params.sendPort?.send(PortProgress(progress / progressMap.length));
          },
        );
      }));
      dataList = (emojiList['dataList'] as List).map((e) => EmojiItemModel.fromJson(e)).toList();
      params.sendPort?.send(PortResult(data: dataList));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  static checkEmoji(_PortModel msg) async {
    /// 检测文件是否存在
    await downEmoji(msg);

    /// 检测表情包是否存在
    final data = msg.data;

    final url = data['url'];
    final path = data['path'];
    String savePath = '${ImCore.dirPath}/$path';
    String fileName = url.substring(url.lastIndexOf('/') + 1, url.length);

    /// 读取json内容
    String jsonStr = File('$savePath/$fileName').readAsStringSync();
    final emojiList = json.decode(jsonStr);
    List<EmojiItemModel> dataList = (emojiList['dataList'] as List).map((e) => EmojiItemModel.fromJson(e)).toList();
    msg.sendPort?.send(PortResult(data: dataList));
  }
}

class Hex {
  /// Creates a `Uint8List` by a hex string.
  static Uint8List createUint8ListFromHexString(String hex) {
    var result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      var num = hex.substring(i, i + 2);
      var byte = int.parse(num, radix: 16);
      result[i ~/ 2] = byte;
    }
    return result;
  }

  /// Returns a hex string by a `Uint8List`.
  static String formatBytesAsHexString(Uint8List bytes) {
    var result = StringBuffer();
    for (var i = 0; i < bytes.lengthInBytes; i++) {
      var part = bytes[i];
      result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return result.toString();
  }
}
