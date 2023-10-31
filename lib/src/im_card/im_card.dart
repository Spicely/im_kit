/*
 * Summary: 文件描述
 * Created Date: 2023-08-16 11:05:17
 * Author: Spicely
 * -----
 * Last Modified: 2023-08-16 11:24:28
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

part of im_kit;

class ImCard extends ImBase {
  const ImCard({
    super.key,
    required super.isMe,
    required super.message,
    required super.contextMenuController,
    super.onTap,
    super.onRevokeTap,
  });
  @override
  Widget build(BuildContext context) {
    ImChatTheme chatTheme = ImKitTheme.of(context).chatTheme;
    return GestureDetector(
      child: Container(
        width: 220,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(247, 247, 247, 1),
          borderRadius: chatTheme.messageTheme.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
          children: [
            const SizedBox(height: 9),
            SizedBox(
              width: 190,
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  CachedImage(
                    imageUrl: message.ext.data?['faceURL'],
                    width: 40,
                    height: 40,
                    circular: 40,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      message.ext.data?['nickname'] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 9),
            const Divider(height: 0.1, color: Color.fromRGBO(151, 151, 151, 0.14)),
            Container(
              alignment: Alignment.centerLeft,
              height: 21,
              child: const Text(
                '个人名片',
                style: TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1)),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        super.onTap?.call(message);
      },
    );
  }
}
