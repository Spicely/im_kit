part of im_kit;
/*
 * Summary: 显示时间组件
 * Created Date: 2023-03-22 09:43:49
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-19 17:44:27
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class ImTime extends StatelessWidget {
  /// 当前消息
  final MessageExt message;

  const ImTime({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    String date = formatDate(context);
    return date.isEmpty
        ? const SizedBox()
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                formatDate(context),
                style: const TextStyle(fontSize: 12, color: Color.fromRGBO(187, 187, 187, 1)),
              ),
            ),
          );
  }

  /// 对时间处理
  String formatDate(BuildContext context) {
    ImLanguage language = ImKitTheme.of(context).language;
    if (message.m.clientMsgID == null) {
      return '';
    }
    DateTime now = DateTime.now();
    DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(message.m.sendTime ?? message.m.createTime!);
    if (now.year == messageTime.year) {
      if (now.month == messageTime.month) {
        if (now.day == messageTime.day) {
          return DateFormat('HH:mm').format(messageTime);
        } else if (now.day - messageTime.day == 1) {
          return '${language.yesterday} ${DateFormat('HH:mm').format(messageTime)}';
        } else if (now.day - messageTime.day <= 7) {
          return '${DateFormat('EEEE').format(messageTime)} ${DateFormat('HH:mm').format(messageTime)}';
        } else {
          return DateFormat('MM-dd HH:mm').format(messageTime);
        }
      } else {
        /// 判断当前日期减去消息日期是否小于7天
        if (now.difference(messageTime).inDays == 1) {
          return '${language.yesterday} ${DateFormat('HH:mm').format(messageTime)}';
        } else if (now.difference(messageTime).inDays <= 7) {
          return '${DateFormat('EEEE').format(messageTime)} ${DateFormat('HH:mm').format(messageTime)}';
        }
        return DateFormat('MM-dd HH:mm').format(messageTime);
      }
    } else {
      return DateFormat('yyyy-MM-dd').format(messageTime);
    }
  }
}
