part of im_kit;

/////////////////////////////////////////////////////////////////////////
//// All rights reserved.
//// author: Spicely
//// Summary: 扩展int类型转成时间戳
//// Date: 2023年10月23日 15:15:48 Monday
//////////////////////////////////////////////////////////////////////////
extension ExtensionIntToTime on int {
  String formatDate({String dateFormatYMD = 'yyyy-MM-dd', String dateFormatMD = 'MM-dd', String yesterday = '昨天'}) {
    DateTime now = DateTime.now();
    DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(this);

    if (now.year == messageTime.year) {
      if (now.month == messageTime.month && now.day == messageTime.day) {
        return DateFormat('HH:mm').format(messageTime);
      } else if (now.day - messageTime.day == 1) {
        return '$yesterday ${DateFormat('HH:mm').format(messageTime)}';
      } else {
        return DateFormat('$dateFormatMD HH:mm').format(messageTime);
      }
    } else {
      return DateFormat(dateFormatYMD).format(messageTime);
    }
  }
}
