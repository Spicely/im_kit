part of im_kit;

const _emojiFaces = <String, String>{
  '[00]': 'ic_face_10000',
  '[01]': 'ic_face_10001',
  '[02]': 'ic_face_10002',
  '[03]': 'ic_face_10003',
  '[04]': 'ic_face_10004',
  '[05]': 'ic_face_10005',
  '[06]': 'ic_face_10006',
  '[07]': 'ic_face_10007',
  '[08]': 'ic_face_10008',
  '[09]': 'ic_face_10009',
  '[10]': 'ic_face_10010',
  '[11]': 'ic_face_10011',
  '[12]': 'ic_face_10012',
  '[13]': 'ic_face_10013',
  '[14]': 'ic_face_10014',
  '[15]': 'ic_face_10015',
  '[16]': 'ic_face_10016',
  '[17]': 'ic_face_10017',
  '[18]': 'ic_face_10018',
  '[19]': 'ic_face_10019',
  '[20]': 'ic_face_10020',
  '[21]': 'ic_face_10021',
  '[22]': 'ic_face_10022',
  '[23]': 'ic_face_10023',
  '[24]': 'ic_face_10024',
  '[25]': 'ic_face_10025',
  '[26]': 'ic_face_10026',
  '[27]': 'ic_face_10027',
  '[28]': 'ic_face_10028',
  '[29]': 'ic_face_10029',
  '[30]': 'ic_face_10030',
  '[31]': 'ic_face_10031',
  '[32]': 'ic_face_10032',
  '[33]': 'ic_face_10033',
  '[34]': 'ic_face_10034',
  '[35]': 'ic_face_10035',
  '[36]': 'ic_face_10036',
  '[37]': 'ic_face_10037',
  '[38]': 'ic_face_10038',
  '[39]': 'ic_face_10039',
  '[40]': 'ic_face_10040',
  '[41]': 'ic_face_10041',
  '[42]': 'ic_face_10042',
  '[43]': 'ic_face_10043',
  '[44]': 'ic_face_10044',
  '[45]': 'ic_face_10045',
  '[46]': 'ic_face_10046',
  '[47]': 'ic_face_10047',
  '[48]': 'ic_face_10048',
  '[49]': 'ic_face_10049',
  '[50]': 'ic_face_10050',
  '[51]': 'ic_face_10051',
  '[52]': 'ic_face_10052',
  '[53]': 'ic_face_10053',
  '[54]': 'ic_face_10054',
  '[55]': 'ic_face_10055',
  '[56]': 'ic_face_10056',
  '[57]': 'ic_face_10057',
  '[58]': 'ic_face_10058',
  '[59]': 'ic_face_10059',
  '[60]': 'ic_face_10060',
  '[61]': 'ic_face_10061',
  '[62]': 'ic_face_10062',
  '[63]': 'ic_face_10063',
  '[64]': 'ic_face_10064',
  '[65]': 'ic_face_10065',
  '[66]': 'ic_face_10066',
  '[67]': 'ic_face_10067',
  '[68]': 'ic_face_10068',
  '[69]': 'ic_face_10069',
  '[70]': 'ic_face_10070',
  '[71]': 'ic_face_10071',
  '[72]': 'ic_face_10072',
  '[73]': 'ic_face_10073',
  '[74]': 'ic_face_10074',
  '[75]': 'ic_face_10075',
  '[76]': 'ic_face_10076',
  '[77]': 'ic_face_10077',
  '[78]': 'ic_face_10078',
  '[79]': 'ic_face_10079',
  '[80]': 'ic_face_10080',
  '[81]': 'ic_face_10081',
  '[82]': 'ic_face_10082',
  '[83]': 'ic_face_10083',
  '[85]': 'ic_face_10085',
  '[86]': 'ic_face_10086',
  '[87]': 'ic_face_10087',
  '[88]': 'ic_face_10088',
  '[89]': 'ic_face_10089',
  '[90]': 'ic_face_10090',
  '[91]': 'ic_face_10091',
  '[92]': 'ic_face_10092',
  '[93]': 'ic_face_10093',
  '[94]': 'ic_face_10094',
  '[95]': 'ic_face_10095',
  '[96]': 'ic_face_10096',
  '[97]': 'ic_face_10097',
  '[98]': 'ic_face_10098',
  '[99]': 'ic_face_10099',
  '[100]': 'ic_face_10100',
};

Widget _getEmoji(String text, {TextStyle? style, double? fontSize, int? maxLines}) {
  /// 获取字符串中 [01] [02] 这样的字符串并依据此字符串进行分割
  var regexEmoji = _emojiFaces.keys.toList().join('|').replaceAll('[', '\\[').replaceAll(']', '\\]');

  RegExp pattern = RegExp(regexEmoji);

  List<InlineSpan> list = [];
  text.splitMapJoin(
    pattern,
    onMatch: (Match m) {
      String value = m.group(0)!;
      String emoji = _emojiFaces[value]!;
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
      list.add(TextSpan(text: _fixAutoLines(parse(n).body?.text ?? '')));
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
