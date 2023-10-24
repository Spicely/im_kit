part of im_kit;

typedef UserNotificationCallback = void Function(UserInfo user);

/// 禁言通知
TextSpan _getGroupMemberMutedNotification(Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  return TextSpan(
    children: [
      TextSpan(
        text: detail['mutedUser']['userID'] == OpenIM.iMManager.uid ? '你' : detail['mutedUser']['nickname'],
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (detail['mutedUser']['userID'] == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [detail['mutedUser']['userID']]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      const TextSpan(text: '被禁言'),
    ],
  );
}

/// 成员进群
TextSpan _getMemberEnterNotification(MessageExt extMsg, {Color? userColor, UserNotificationCallback? onTap}) {
  var entrantUser = extMsg.ext.data['entrantUser'];
  return TextSpan(
    children: [
      TextSpan(
        text: entrantUser['userID'] == OpenIM.iMManager.uid ? '你' : entrantUser['nickname'],
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (entrantUser['userID'] == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [entrantUser['userID']]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      const TextSpan(text: '进入群组'),
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

/// 取消禁言
TextSpan _getGroupMemberCancelMutedNotification(Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  return TextSpan(
    children: [
      TextSpan(
        text: detail['mutedUser']['userID'] == OpenIM.iMManager.uid ? '你' : detail['mutedUser']['nickname'],
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (detail['mutedUser']['userID'] == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              List<UserInfo> users = await OpenIM.iMManager.userManager.getUsersInfo(uidList: [detail['mutedUser']['userID']]);
              onTap?.call(users[0]);
            }
          },
      ),
      const TextSpan(text: '被取消禁言'),
    ],
  );
}

/// 修改了群组资料
TextSpan _getGroupInfoSetNotification(Map<String, dynamic> detail, {Color? userColor, UserNotificationCallback? onTap}) {
  return TextSpan(
    children: [
      TextSpan(
        text: detail['opUser']['userID'] == OpenIM.iMManager.uid ? '你' : detail['opUser']['nickname'],
        style: TextStyle(color: userColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (detail['opUser']['userID'] == OpenIM.iMManager.uid) {
              onTap?.call(OpenIM.iMManager.uInfo!);
            } else {
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [detail['opUser']['userID']]).then((users) {
                onTap?.call(users.first);
              });
            }
          },
      ),
      const TextSpan(text: '修改了群组资料'),
    ],
  );
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
              OpenIM.iMManager.userManager.getUsersInfo(uidList: [detail['red_envelope_user_id']]).then((users) {
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
