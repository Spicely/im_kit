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
        MessageType.merger => TextSpan(text: isSingleChat ? '[合并消息]' : '$senderNickname: [合并消息]'),
        MessageType.advancedRevoke => TextSpan(text: isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]'),
        MessageType.text || MessageType.advancedText || MessageType.at_text => _getAtText(this),
        MessageType.revoke => TextSpan(text: '$senderNickname撤回了一条消息'),
        300 => TextSpan(text: isSingleChat ? '[表情]' : '$senderNickname: [表情]'),
        MessageType.groupMemberMutedNotification => _getGroupMemberMutedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.groupMemberCancelMutedNotification => _getGroupMemberCancelMutedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberInvitedNotification => _getMemberInvitedNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.memberEnterNotification => _getMemberEnterNotification(jsonDecode(notificationElem?.detail ?? '{}')),
        MessageType.custom => switch (jsonDecode(customElem?.data ?? '{}')['contentType']) {
            81 => const TextSpan(text: '[红包消息]'),
            82 => TextSpan(text: '$senderNickname领取了你的红包'),
            83 => const TextSpan(text: '[转账消息]'),
            84 => const TextSpan(text: '[红包退还消息]'),
            _ => const TextSpan(text: '暂不支持的消息'),
          },
        _ => const TextSpan(text: '暂不支持的消息'),
      };
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
}
