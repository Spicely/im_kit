part of im_kit;

typedef UserNotificationCallback = void Function(UserInfo user);

/// 踢出群组
TextSpan _getMemberKickedNotification(Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  List<dynamic> kickedUserList = detail['kickedUserList'];
  return TextSpan(
    children: [
      ...kickedUserList
          .map(
            (v) => TextSpan(
              text: v['userID'] == OpenIM.iMManager.uid ? '你${kickedUserList.indexOf(v) + 1 == kickedUserList.length ? '' : '、'}' : '${v['nickname']}${kickedUserList.indexOf(v) + 1 == kickedUserList.length ? '' : '、'}',
              style: TextStyle(color: userColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  print(v);
                  if (v['userID'] == OpenIM.iMManager.uid) {
                    onTap?.call(OpenIM.iMManager.uInfo!);
                  } else {
                    List<UserInfo> users = await OpenIM.iMManager.userManager.getUsersInfo(uidList: [v['userID']]);
                    onTap?.call(users[0]);
                  }
                },
            ),
          )
          .toList(),
      const TextSpan(text: '被踢出群组'),
    ],
  );
}

/// 撤回消息
TextSpan _getRevoke(MessageExt extMsg, {Color? userColor, UserNotificationCallback? onTap}) {
  return TextSpan(
    children: [
      TextSpan(
        text: extMsg.m.sendID == OpenIM.iMManager.uid ? '你' : extMsg.m.senderNickname,
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (extMsg.m.sendID == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [extMsg.m.sendID!]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      const TextSpan(text: '撤回了一条消息'),
    ],
  );
}

/// 邀请进群
TextSpan _getMemberInvitedNotification(Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  List<dynamic> invitedUserList = detail['invitedUserList'];
  return TextSpan(
    children: [
      ...invitedUserList
          .map(
            (v) => TextSpan(
              text: v['userID'] == OpenIM.iMManager.uid ? '你${invitedUserList.indexOf(v) + 1 == invitedUserList.length ? '' : '、'}' : '${v['nickname']}${invitedUserList.indexOf(v) + 1 == invitedUserList.length ? '' : '、'}',
              style: TextStyle(color: userColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (v['userID'] == OpenIM.iMManager.uid) {
                    onTap?.call(OpenIM.iMManager.uInfo!);
                  } else {
                    List<UserInfo> users = await OpenIM.iMManager.userManager.getUsersInfo(uidList: [v['userID']]);
                    onTap?.call(users[0]);
                  }
                },
            ),
          )
          .toList(),
      const TextSpan(text: '被邀请进入群组'),
    ],
  );
}

/// 修改了群组资料
TextSpan _getNotification(Map<String, dynamic> detail, int type, {Color? userColor, UserNotificationCallback? onTap}) {
  String? userId = detail['opUser']?['userID'] ?? detail['mutedUser']?['userID'] ?? detail['entrantUser']?['userID'];
  String? nickname = detail['opUser']?['nickname'] ?? detail['mutedUser']?['nickname'] ?? detail['entrantUser']?['nickname'];
  return TextSpan(
    children: [
      TextSpan(
        text: userId == OpenIM.iMManager.uid ? '你' : nickname,
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (userId == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [userId!]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      TextSpan(text: _getTypeText(type)),
    ],
  );
}

String _getTypeText(int type) {
  return switch (type) {
    MessageType.groupCreatedNotification => '创建了群组',
    MessageType.groupMemberCancelMutedNotification => '被取消禁言',
    MessageType.groupMemberMutedNotification => '被禁言',
    MessageType.memberEnterNotification => '进入群组',
    _ => '暂不支持的消息',
  };
}

/// 修改了群组资料
TextSpan _getRedEnvelope(MessageExt extMsg, Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  return TextSpan(
    children: [
      TextSpan(
        text: extMsg.m.sendID == OpenIM.iMManager.uid ? '你' : extMsg.m.senderNickname,
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (extMsg.m.sendID == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [extMsg.m.sendID!]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      const TextSpan(text: '领取了'),
      TextSpan(text: detail['red_envelope_user_id'] == OpenIM.iMManager.uid ? '你' : detail['red_envelope_user_name']),
      const TextSpan(text: '的红包'),
    ],
  );
}

TextSpan _getAtText(Message msg) {
  String v = msg.atElem?.text ?? msg.content ?? '';
  List<AtUserInfo> atUsersInfo = msg.atElem?.atUsersInfo ?? [];

  List<ImAtTextType> list = [];

  /// 匹配艾特用户
  String atReg = atUsersInfo.map((v) => '@${v.atUserID} ').join('|');

  var regexEmoji = _emojiFaces.keys.toList().map((e) => RegExp.escape(e)).join('|');

  String regExp;
  if (atUsersInfo.isEmpty) {
    regExp = [regexEmoji].join('|');
  } else {
    regExp = [regexEmoji, atReg].join('|');
  }
  v.splitMapJoin(
    RegExp('($regExp)'),
    onMatch: (Match m) {
      String value = m.group(0)!;
      if (RegExp(regexEmoji).hasMatch(value)) {
        String emoji = _emojiFaces[value]!;
        list.add(ImAtTextType(type: ImAtType.emoji, text: emoji));
      } else if (RegExp(atReg).hasMatch(value)) {
        String id = value.replaceAll('@', '').trim();
        AtUserInfo? atUserInfo = atUsersInfo.firstWhereOrNull((v) => v.atUserID == id);
        if (atUserInfo == null) {
          list.add(ImAtTextType(type: ImAtType.text, text: value));
        } else {
          if (atUserInfo.atUserID == OpenIM.iMManager.uid) {
            list.add(ImAtTextType(type: ImAtType.at, text: '@你 ', userInfo: atUserInfo));
          } else {
            list.add(ImAtTextType(type: ImAtType.at, text: '@${atUserInfo.groupNickname} ', userInfo: atUserInfo));
          }
        }
      }
      return '';
    },
    onNonMatch: (String n) {
      list.add(ImAtTextType(type: ImAtType.text, text: n));
      return '';
    },
  );
  return TextSpan(
    children: [
      msg.isGroupChat ? TextSpan(text: '${msg.senderNickname}：') : const TextSpan(),
      ...list.map((e) {
        if (e.type == ImAtType.emoji) {
          return WidgetSpan(
            child: CachedImage(
              assetUrl: 'assets/emoji/${e.text}.webp',
              width: 15,
              height: 15,
              package: 'im_kit',
            ),
          );
        } else {
          return TextSpan(text: e.text);
        }
      }).toList(),
    ],
  );
}
