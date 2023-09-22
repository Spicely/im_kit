// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, deprecated_export_use

part of im_kit;

const ROADOM_STR = "bwGO8X5gdaM5dsV@";

class IsolateMethod {
  /// 下载多文件
  static Future<void> downloadFiles(_PortModel params) async {
    try {
      Map<String, dynamic> progressMap = {};
      List<Map<String, String>> urls = params.data;
      bool status = urls.every((v) {
        File file = File(v['savePath']!);
        if (file.existsSync()) {
          return true;
        } else {
          return false;
        }
      });

      if (status) {
        params.sendPort?.send(PortResult(data: urls.map((e) => e['savePath']!).toList()));
        return;
      }
      await Future.wait(urls.map((e) {
        progressMap[e['url']!] = {'count': 0, 'total': 0};
        return Dio().download(e['url']!, e['savePath'], onReceiveProgress: (count, total) {
          progressMap[e['url']!] = {'count': count, 'total': total};
          double progress = 0;
          progressMap.forEach((key, value) {
            if (value['total'] == 0) return;
            progress += value['count'] / value['total'];
          });
          params.sendPort?.send(PortProgress(progress / progressMap.length));
        });
      }).toList());

      params.sendPort?.send(PortResult(data: urls.map((e) => e['savePath']!).toList()));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  /// 加密文件
  static Future<void> encryptFile(_PortModel params) async {
    try {
      String key = params.data['key'];
      final iv = enc.IV.fromUtf8(params.data['iv']);
      String path = params.data['path'];

      final fileByte = File(path).readAsBytesSync();

      DecDataRes res2 = DecDataRes.fromByUint8list(fileByte, key, decIV: iv);
      if (res2.isEncData != 0) return;
      Uint8List encdata = res2.encData;

      /// 写入加密后的文件
      File file = File(path);
      file.writeAsBytesSync(encdata, flush: true);
      params.sendPort?.send(PortResult(data: ''));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  /// 解开密文件
  static Future<void> decryptFile(_PortModel params) async {
    try {
      String key = params.data['key'];
      String iv = params.data['iv'];
      String filePath = params.data['filePath'];

      final fileByte = await File(filePath).readAsBytes();
      DecDataRes res2 = DecDataRes.fromByUint8list(fileByte, key, decIV: enc.IV.fromUtf8(iv));
      if (res2.isEncData == 0) {
        params.sendPort?.send(PortResult(data: filePath));
        return;
      }
      Uint8List decData = res2.decFile;
      File file = File(filePath);
      await file.writeAsBytes(decData, flush: true);
      params.sendPort?.send(PortResult(data: filePath));
    } catch (e) {
      params.sendPort?.send(PortResult(error: e.toString()));
    }
  }

  /// 获取图片信息
  static void getImageInfo(_PortModel params) async {
    String path = params.data['path'];

    /// 获取图片宽高
    final List<int> bytes = await File(path).readAsBytes();
    final img.Image? decodedImage = img.decodeImage(Uint8List.fromList(bytes));

    /// 获取文件后缀名
    String fileType = File(path).path.split('.').last;
    if (decodedImage != null) {
      final int width = decodedImage.width;
      final int height = decodedImage.height;

      params.sendPort?.send(PortResult(data: (fileType, width, height)));
    } else {
      params.sendPort?.send(PortResult(data: (fileType, 0, 0)));
    }
  }

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
}

class DecDataRes {
  String key = "";

  enc.IV? decIV;

  int headerLen = 0;

  ///自定义文件头的长度

  int isEncData = 0;

  ///是否加密 0 未加密， 1加密 2数据错误

  Uint8List source = Uint8List(0);

  ///加密文件源

  int maxEncLen = 320 * 1024;

  ///解密需要操作的长度

  static DecDataRes fromByUint8list(Uint8List fileList, String key, {int headerLength = 64, enc.IV? decIV}) {
    DecDataRes result = DecDataRes();
    result.key = key;
    result.decIV = decIV;
    result.source = fileList;
    result.headerLen = headerLength;
    if (fileList.length < headerLength) return result;

    /// 通过我们自定义的字符串来对比是否相等是否为加密文件
    List<int> radomStr = utf8.encode(ROADOM_STR);
    for (int i = 0; i < radomStr.length; i++) {
      if (result.header[i] != radomStr[i]) {
        result.isEncData = 0;
        return result;
      }
    }
    result.isEncData = 1;
    if (result.source.length >= (headerLength + result.encLen)) {
    } else {
      result.isEncData = 2;
    }

    return result;
  }

  ///解密需要操作的长度
  int get encLen => EncryptExtends.u8ToInt(source.sublist(24, 28));

  ///文件的长度(解密过后文件的长度)
  int get fileLen => EncryptExtends.u8ToInt(source.sublist(20, 24));

  ///文件头
  Uint8List get header {
    return source.sublist(0, headerLen);
  }

  ///加密段
  Uint8List get encdata {
    return source.sublist(headerLen, headerLen + encLen);
  }

  ///得到解密过后的字段
  Uint8List get decdata {
    return EncryptExtends.DEC_U8L_AES_P7(plainText: encdata, keyStr: key, iv: decIV!);
  }

  ///得到解密过后的完整文件
  Uint8List get decFile {
    List<int> res = [];
    res.addAll(decdata);
    if (source.length > headerLen + encLen) {
      res.addAll(source.sublist(headerLen + encLen));
    }
    return Uint8List.fromList(res);
  }

  ///出去加密剩余的不加密的部分，如果没有为Uint8List(0)
  Uint8List get other {
    if (source.length > headerLen + encLen) {
      return source.sublist(64 + encLen);
    }
    return Uint8List(0);
  }

  Map toJson() {
    return {
      "headerLen": headerLen,
      "isEncData": isEncData,
      "encLen": encLen,
      "fileLen": fileLen,
      "source": source.length,
      "header": header.length,
      "other": other.length,
    };
  }

  Uint8List get encData {
    Uint8List list = source;
    List<int> head = [];
    Uint8List encData = Uint8List(0);
    Uint8List otherData = Uint8List(0);
    List<int> newFile = [];

    if (list.length <= maxEncLen) {
      ///全加密
      encData = EncryptExtends.ENC_U8L_AES_P7(plainText: list, keyStr: key, iv: decIV!);
    } else {
      encData = EncryptExtends.ENC_U8L_AES_P7(plainText: list.sublist(0, 327680), keyStr: key, iv: decIV!);
      otherData = list.sublist(maxEncLen);
    }
    List<int> b0 = utf8.encode(ROADOM_STR);
    List<int> b1 = Int2Bytes.convert(maxEncLen).reversed.toList();

    ///定义的加密长度 len=4
    List<int> b2 = Int2Bytes.convert(list.length).reversed.toList();

    ///文件原长度    len=4
    List<int> b3 = Int2Bytes.convert(encData.length).reversed.toList();

    ///文件加密过后长度

    head.addAll(b0);

    if (b1.length < 4) {
      List<int> _t = [];
      for (int i = 0; i < 4 - b1.length; i++) {
        _t.add(0);
      }
      b1.addAll(_t);
    }
    head.addAll(b1);

    if (b2.length < 4) {
      List<int> _t = [];
      for (int i = 0; i < 4 - b2.length; i++) {
        _t.add(0);
      }
      b2.addAll(_t);
    }
    head.addAll(b2);

    if (b3.length < 4) {
      List<int> _t = [];
      for (int i = 0; i < 4 - b3.length; i++) {
        _t.add(0);
      }
      b3.addAll(_t);
    }
    head.addAll(b3);

    if (head.length < 64) {
      List<int> _t = [];
      for (int i = 0; i < 64 - head.length; i++) {
        _t.add(0);
      }
      head.addAll(_t);
    }

    // print(head);
    // print(head.length);
    // print(b0);

    ///  16 16-20(加密长度) 20-24(文件长度) 24-28(加密操作的长度)  0 0 0 0 0
    // print(head.sublist(20,24));///[11, 62, 0, 0]
    // print(head.sublist(24,28));///[16, 62, 0, 0]

    newFile.addAll(head);
    newFile.addAll(encData);
    newFile.addAll(otherData);
    // print("=====加密后的长度:${newFile.length}======");

    return Uint8List.fromList(newFile);
  }
}

class EncryptExtends {
  static Uint8List ZeroPadding(Uint8List plaintext, int blockSize) {
    int padLength = (blockSize - (plaintext.lengthInBytes % blockSize)) % blockSize;
    if (padLength != 0) {
      BytesBuilder bb = BytesBuilder();
      Uint8List padding = Uint8List(padLength);
      bb.add(plaintext);
      bb.add(padding);
      return bb.toBytes();
    } else {
      return plaintext;
    }
  }

  /// PKCS7加解密字符串
  static enc.Encrypted ENC_STR_AES_UTF8_P7({required String plainText, required String keyStr, required enc.IV iv}) {
    final key = enc.Key.fromUtf8(keyStr);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(plainText, iv: iv);
  }

  static String DEC_STR_AES_UTF8_P7({required String plainText, required String keyStr, required enc.IV iv}) {
    final key = enc.Key.fromUtf8(keyStr);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    try {
      return encrypter.decrypt(enc.Encrypted.fromBase64(plainText), iv: iv);
    } catch (e) {
      return plainText;
    }
  }

  static enc.Encrypted ENC_STR_AES_UTF8_ZP({required String plainText, required String keyStr}) {
    final key = enc.Key.fromUtf8(keyStr);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: null));
    final dataPadded = ZeroPadding(Uint8List.fromList(utf8.encode(plainText)), keyStr.length);
    return encrypter.encryptBytes(dataPadded, iv: enc.IV.fromUtf8(keyStr));
  }

  static String decStrAesUtf8ZP({required String plainText, required String keyStr}) {
    try {
      if (plainText.isEmpty) return "";
      final key = enc.Key.fromUtf8(keyStr);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: null));
      final resStr = encrypter.decrypt(enc.Encrypted.fromBase64(plainText), iv: enc.IV.fromUtf8(keyStr));
      final resList = utf8.encode(resStr).reversed.toList();
      final index = resList.indexWhere((v) => v > 0);
      final newList = resList.sublist(index);
      return utf8.decode(newList.reversed.toList());
    } catch (e) {
      return plainText;
    }
  }

  static Uint8List ENC_U8L_AES_P7({required Uint8List plainText, required String keyStr, required enc.IV iv}) {
    final key = enc.Key.fromUtf8(keyStr);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.encryptBytes(plainText, iv: iv).bytes;
  }

  /// DEC_U8L_AES_P7
  static Uint8List DEC_U8L_AES_P7({
    required Uint8List plainText,
    required String keyStr,
    required enc.IV iv,
  }) {
    final key = enc.Key.fromUtf8(keyStr);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    List<int> decList = encrypter.decryptBytes(enc.Encrypted(plainText), iv: iv);
    return Uint8List.fromList(decList);
  }

  static int u8ToInt(Uint8List u8) {
    int n = 0;
    for (var i = 0; i < 4; i++) {
      n += u8[i] << i * 8;
    }
    return n;
  }

  static int intToU8(Uint8List u8) {
    int n = 0;
    for (var i = 0; i < 4; i++) {
      n += u8[i] << i * 8;
    }
    return n;
  }
}

enum Type {
  BYTE,

  /// 1
  WORD,

  /// 2
  DWORD,

  /// 4
  STRING
}

class Int2Bytes {
  static List<int> convert(int source, {Type type = Type.WORD}) {
    var s = source.toRadixString(16);
    var pre = '0';
    if (s.length % 2 == 1) {
      s = pre + s;
    }
    List<int> list = [];
    var uint8list = Hex.createUint8ListFromHexString(s);
    switch (type) {
      case Type.BYTE:
        break;
      case Type.WORD:
        if (uint8list.length == 1) {
          list.add(0);
        }
        break;
      case Type.DWORD:
        for (var i = 0; i < 4 - uint8list.length; i++) {
          list.add(0);
        }
        break;
      default:
    }
    list.addAll(uint8list);
    return list;
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
