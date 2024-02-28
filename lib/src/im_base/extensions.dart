part of im_kit;

extension ExtensionAdvancedMessage on AdvancedMessage {
  Future<List<MessageExt>> toExt() async {
    return Future.wait((messageList ?? []).map((e) => e.toExt()));
  }
}

extension ExtensionMessage on Message {
  Future<MessageExt> toExt() async {
    return await ImKitIsolateManager.toMessageExt(this);
  }

  /// 显示名称
  String get name {
    if (isGroupChat) {
      return senderNickname ?? '';
    } else {
      try {
        Map<String, dynamic> map = jsonDecode(senderNickname ?? '{}');
        return Utils.getValue(map['remark'], map['nickname']) ?? '';
      } catch (e) {
        return senderNickname ?? '';
      }
    }
  }

  /// 消息类型
  InlineSpan get type => switch (contentType) {
        MessageType.picture => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[图片]' : '$senderNickname: [图片]')),
        MessageType.file => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[文件]' : '$senderNickname: [文件]')),
        MessageType.video => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[视频]' : '$senderNickname: [视频]')),
        MessageType.voice => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[语音]' : '$senderNickname: [语音]')),
        MessageType.location => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[位置]' : '$senderNickname: [位置]')),
        MessageType.card => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[用户名片]' : '$senderNickname: [用户名片]')),
        MessageType.quote => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[引用消息]' : '$senderNickname: [引用消息]')),
        MessageType.merger => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[合并消息]' : '$senderNickname: [合并消息]')),
        MessageType.groupMutedNotification => TextSpan(text: ImCore.fixAutoLines('群组开启禁言')),
        MessageType.groupCancelMutedNotification => TextSpan(text: ImCore.fixAutoLines('群组取消禁言')),
        MessageType.advancedRevoke => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]')),
        MessageType.text || MessageType.advancedText || MessageType.at_text => _getAtText(this),
        MessageType.revoke => TextSpan(text: ImCore.fixAutoLines('$senderNickname撤回了一条消息')),
        MessageType.friendAddedNotification => TextSpan(text: ImCore.fixAutoLines('添加好友成功')),
        MessageType.oaNotification => TextSpan(text: ImCore.fixAutoLines(jsonDecode(notificationElem?.detail ?? '{}')['notificationName'])),
        300 => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[表情]' : '$senderNickname: [表情]')),
        MessageType.burnAfterReadingNotification => TextSpan(text: ImCore.fixAutoLines(jsonDecode(notificationElem?.detail ?? '{}')['isPrivate'] == true ? '阅后即焚已开启' : '阅后即焚已关闭')),
        MessageType.memberInvitedNotification => _getMemberInvitedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberKickedNotification => _getMemberKickedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberEnterNotification ||
        MessageType.groupMemberMutedNotification ||
        MessageType.groupCreatedNotification ||
        MessageType.groupMemberCancelMutedNotification ||
        MessageType.groupInfoSetNotification ||
        MessageType.memberQuitNotification =>
          _getNotification(jsonDecode(notificationElem?.detail ?? '{}'), contentType!),
        MessageType.custom => switch (jsonDecode(customElem?.data ?? '{}')['contentType']) {
            10 => TextSpan(text: ImCore.fixAutoLines('[邀请通知]')),
            11 => TextSpan(text: ImCore.fixAutoLines('[同意通话]')),
            12 => TextSpan(text: ImCore.fixAutoLines('[拒绝通话]')),
            13 => TextSpan(text: ImCore.fixAutoLines('[取消通话]')),
            14 => TextSpan(text: ImCore.fixAutoLines('[挂断通话]')),
            15 => TextSpan(text: ImCore.fixAutoLines('[邀请超时]')),
            27 => TextSpan(text: ImCore.fixAutoLines('双方聊天记录已清空')),
            77 => TextSpan(text: ImCore.fixAutoLines('群主清除了聊天记录')),
            81 => TextSpan(text: ImCore.fixAutoLines('[红包消息]')),
            // 82 => _getRedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
            83 => TextSpan(text: ImCore.fixAutoLines('[转账消息]')),
            84 => TextSpan(text: ImCore.fixAutoLines('[红包退还消息]')),
            2024 => TextSpan(text: ImCore.fixAutoLines('[对方不是你的好友]'), style: const TextStyle(color: Colors.red)),
            2025 => TextSpan(text: ImCore.fixAutoLines('[对方拒收你的消息]'), style: const TextStyle(color: Colors.red)),
            _ => TextSpan(text: ImCore.fixAutoLines('暂不支持的消息')),
          },
        _ => TextSpan(text: ImCore.fixAutoLines('暂不支持的消息')),
      };

  bool isExJson() {
    try {
      Map<String, dynamic> _ = json.decode(ex ?? '');
      return true;
    } catch (e) {
      return false;
    }
  }
}

extension ExtensionConversationInfo on ConversationInfo {
  String title({int? number}) {
    if (isGroupChat) {
      return number != null && number != 0 ? '$showName($number)' : showName ?? '';
    } else {
      try {
        Map<String, dynamic> map = jsonDecode(showName ?? '{}');
        return Utils.getValue(map['remark'], map['nickname']) ?? showName ?? '';
      } catch (e) {
        return showName ?? '';
      }
    }
  }

  /// 群是否已解散
  bool get isGroupDissolution {
    if (latestMsg?.contentType == MessageType.dismissGroupNotification) {
      return true;
    }
    return false;
  }

  /// 显示名称信息
  UserName get name {
    if (isGroupChat) {
      return UserName(nickName: showName ?? '');
    } else {
      try {
        Map<String, dynamic> map = jsonDecode(showName ?? '{}');
        return UserName.fromJson(map);
      } catch (e) {
        return UserName(nickName: showName ?? '');
      }
    }
  }

  /// 显示名称
  String get nickName => Utils.getValue(name.remark, name.nickName);
}

extension ExtensionUserInfo on UserInfo {
  /// 显示名称信息
  UserName get name {
    try {
      Map<String, dynamic> map = jsonDecode(getShowName());
      return UserName.fromJson(map);
    } catch (e) {
      return UserName(nickName: getShowName());
    }
  }

  /// 显示名称
  String get nickName => Utils.getValue(name.remark, name.nickName);

  /// 个性签名
  String get signature {
    try {
      Map<String, dynamic> map = jsonDecode(Utils.getValue(ex, '{}'));
      return map['desc'];
    } catch (e) {
      return '';
    }
  }
}

class UserName {
  final String remark;
  final String nickName;

  UserName({this.remark = '', this.nickName = ''});

  factory UserName.fromJson(Map<String, dynamic> json) {
    return UserName(
      remark: json['remark'] ?? '',
      nickName: json['nickname'] ?? '',
    );
  }
}
// extension ExtensionUserInfo on UserInfo {
//   String get showName {
//     try {
//       Map<String, dynamic> map = jsonDecode(nickName ?? '{}');
//       return Utils.getValue(map['remark'], map['nickname']) ?? '';
//     } catch (e) {
//       return nickName ?? '';
//     }
//   }
//  }