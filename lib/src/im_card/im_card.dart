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
    Key? key,
    required bool isMe,
    required MessageExt message,
  }) : super(key: key, isMe: isMe, message: message);
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: theme.borderRadius,
        ),
        padding: theme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListItem(
              contentPadding: EdgeInsets.zero,
              leading: CachedImage(
                imageUrl: message.m.cardElem?.faceURL ?? '',
                width: 40,
                height: 40,
                circular: 5,
              ),
              valueAlignment: Alignment.centerLeft,
              value: Text(
                message.m.cardElem?.nickname ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.fontColor, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
