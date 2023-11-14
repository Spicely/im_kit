part of im_kit;

extension ExtensionAdvancedMessage on AdvancedMessage {
  Future<List<MessageExt>> toExt(String secretKey) async {
    return Future.wait((messageList ?? []).map((e) => e.toExt(secretKey)));
  }
}

extension ExtensionMessage on Message {
  Future<MessageExt> toExt(String secretKey) async {
    return await ImKitIsolateManager.toMessageExt(OpenIM.iMManager.uid!, this, secretKey);
  }

  /// 消息类型
  InlineSpan get type => switch (contentType) {
        MessageType.picture => TextSpan(text: isSingleChat ? '[图片]' : '$senderNickname: [图片]'),
        MessageType.file => TextSpan(text: isSingleChat ? '[文件]' : '$senderNickname: [文件]'),
        MessageType.video => TextSpan(text: isSingleChat ? '[视频]' : '$senderNickname: [视频]'),
        MessageType.voice => TextSpan(text: isSingleChat ? '[语音]' : '$senderNickname: [语音]'),
        MessageType.location => TextSpan(text: isSingleChat ? '[位置]' : '$senderNickname: [位置]'),
        MessageType.card => TextSpan(text: isSingleChat ? '[用户名片]' : '$senderNickname: [用户名片]'),
        MessageType.quote => TextSpan(text: isSingleChat ? '[引用消息]' : '$senderNickname: [引用消息]'),
        MessageType.merger => TextSpan(text: isSingleChat ? '[合并消息]' : '$senderNickname: [合并消息]'),
        MessageType.groupMutedNotification => const TextSpan(text: '群组开启禁言'),
        MessageType.groupCancelMutedNotification => const TextSpan(text: '群组取消禁言'),
        MessageType.advancedRevoke => TextSpan(text: isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]'),
        MessageType.text || MessageType.advancedText || MessageType.at_text => _getAtText(this),
        MessageType.revoke => TextSpan(text: '$senderNickname撤回了一条消息'),
        300 => TextSpan(text: isSingleChat ? '[表情]' : '$senderNickname: [表情]'),
        MessageType.burnAfterReadingNotification => TextSpan(text: jsonDecode(notificationElem?.detail ?? '{}')['isPrivate'] == true ? '阅后即焚已开启' : '阅后即焚已关闭'),
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
            10 => const TextSpan(text: '[邀请通知]'),
            11 => const TextSpan(text: '[同意通话]'),
            12 => const TextSpan(text: '[拒绝通话]'),
            13 => const TextSpan(text: '[取消通话]'),
            14 => const TextSpan(text: '[挂断通话]'),
            15 => const TextSpan(text: '[邀请超时]'),
            27 => const TextSpan(text: '双方聊天记录已清空'),
            77 => const TextSpan(text: '群主清除了聊天记录'),
            81 => const TextSpan(text: '[红包消息]'),
            // 82 => _getRedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
            83 => const TextSpan(text: '[转账消息]'),
            84 => const TextSpan(text: '[红包退还消息]'),
            _ => const TextSpan(text: '暂不支持的消息'),
          },
        _ => const TextSpan(text: '暂不支持的消息'),
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
}
