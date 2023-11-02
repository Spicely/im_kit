part of im_kit;

Widget _getEmoji(String text, {TextStyle? style, double? fontSize, int? maxLines}) {
  /// 获取字符串中 [01] [02] 这样的字符串并依据此字符串进行分割

  var regexEmoji = ImCore.emojiFaces.keys.toList().join('|').replaceAll('[', '\\[').replaceAll(']', '\\]');

  RegExp pattern = RegExp(regexEmoji);

  List<InlineSpan> list = [];
  text.splitMapJoin(
    pattern,
    onMatch: (Match m) {
      String value = m.group(0)!;
      String emoji = ImCore.emojiFaces[value]!;
      list.add(WidgetSpan(
        child: CachedImage(
          assetUrl: 'assets/emoji/$emoji.webp',
          width: fontSize ?? 25,
          height: fontSize ?? 25,
          package: 'im_kit',
        ),
      ));
      return '';
    },
    onNonMatch: (String n) {
      n = n.replaceAll('@-1', '@所有人 ');
      list.add(TextSpan(text: ImCore.fixAutoLines(parse(n).body?.text ?? '')));
      return '';
    },
  );
  return Text.rich(
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: style,
    TextSpan(
      children: list,
    ),
  );
}

class Emoji {
  String? emoticonsId;
  String? name;
  String? introduce;
  String? sampleDiagramUrl;
  String? url;
  int? size;

  List<EmojiItemModel>? emojiList;

  Emoji({this.emoticonsId, this.name, this.introduce, this.sampleDiagramUrl, this.url, this.size});

  Emoji.fromJson(Map<String, dynamic> json) {
    emoticonsId = json['emoticons_id'];
    name = json['name'];
    introduce = json['introduce'];
    sampleDiagramUrl = json['sample_diagram_url'];
    url = json['url'];
    size = json['size'];
    emojiList = (json['emojiList'] as List?)?.map((e) => EmojiItemModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['emoticons_id'] = emoticonsId;
    data['name'] = name;
    data['introduce'] = introduce;
    data['sample_diagram_url'] = sampleDiagramUrl;
    data['url'] = url;
    data['size'] = size;
    data['emojiList'] = emojiList?.map((e) => e.toJson()).toList();
    return data;
  }
}

class EmojiItemModel {
  final String name;

  final double w;

  final double h;

  EmojiItemModel({
    required this.name,
    required this.w,
    required this.h,
  });

  factory EmojiItemModel.fromJson(Map<String, dynamic> json) => EmojiItemModel(
        name: json['name'],
        w: (json['w'] as num).toDouble(),
        h: (json['h'] as num).toDouble(),
      );

  toJson() => {
        'name': name,
        'w': w,
        'h': h,
      };
}
