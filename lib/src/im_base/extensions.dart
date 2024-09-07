part of im_kit;

extension ExtensionAdvancedMessage on AdvancedMessage {
  Future<List<MessageExt>> toExt() async {
    return Future.wait(messageList.map((e) => e.toExt()));
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
        MessageType.revokeMessageNotification => TextSpan(text: ImCore.fixAutoLines(isSingleChat ? '[撤回消息]' : '$senderNickname: [撤回消息]')),
        MessageType.text || MessageType.advancedText || MessageType.atText => _getAtText(this),
        // MessageType.revoke => TextSpan(text: ImCore.fixAutoLines('$senderNickname撤回了一条消息')),
        MessageType.friendAddedNotification => TextSpan(text: ImCore.fixAutoLines('添加好友成功')),
        MessageType.friendAddedNotification || MessageType.friendApplicationApprovedNotification => TextSpan(text: ImCore.fixAutoLines('你们已成为好友，可以开始聊天了')),
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
        MessageType.groupOwnerTransferredNotification ||
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
    bool isFileHelper = userID == OpenIM.iMManager.uid;
    if (isFileHelper) return '文件助手';
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

extension ExtensionGroupApplicationInfo on GroupApplicationInfo {
  /// 转到ApplicationInfo
  ApplicationInfo toApplicationInfo() {
    String reason = '';
    try {
      Map<String, dynamic> map = jsonDecode(reqMsg ?? '');
      reason = map['reason'];
    } catch (e) {
      reason = reqMsg ?? '';
    }
    return ApplicationInfo(
      type: ApplicationInfoType.group,
      id: userID,
      groupID: groupID,
      nickname: nickname,
      faceUrl: groupFaceURL,
      userFaceURL: userFaceURL,
      gender: gender,
      handleResult: handleResult,
      reqMsg: reason,
      handledMsg: handledMsg,
      reqTime: reqTime,
      handleUserID: handleUserID,
      handledTime: handledTime,
      ex: ex,
      joinSource: joinSource,
    );
  }
}

extension ExtensionGroupInfo on GroupInfo {
  /// 0 id名称都允许搜索
  ///
  /// 1 Id允许搜索 名称不允许搜索
  ///
  /// 2 名称允许搜索 Id不允许搜索
  ///
  /// 3 都不允许
  int get searchType {
    try {
      Map<String, dynamic> map = jsonDecode(ex ?? '{}');
      return map['search_opt'];
    } catch (e) {
      return 0;
    }
  }
}

extension ExtensionFriendApplicationInfo on FriendApplicationInfo {
  /// 转到ApplicationInfo
  ApplicationInfo toApplicationInfo() {
    String reason = '';
    try {
      Map<String, dynamic> map = jsonDecode(reqMsg ?? '');
      reason = map['reason'];
    } catch (e) {
      reason = reqMsg ?? '';
    }
    return ApplicationInfo(
      type: ApplicationInfoType.friend,
      id: fromUserID,
      nickname: fromNickname,
      faceUrl: fromFaceURL,
      userFaceURL: fromFaceURL,
      // gender: fromGender,
      handleResult: handleResult,
      reqMsg: reason,
      handledMsg: handleMsg,
      reqTime: createTime,
      handleUserID: handlerUserID,
      handledTime: handleTime,
      ex: ex,
    );
  }
}

enum ApplicationInfoType {
  group,
  friend,
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

class ApplicationInfo {
  String? id;

  /// 群ID
  String? groupID;

  /// 头像
  String? faceUrl;

  /// 昵称
  String? nickname;

  /// 发起入群申请的用户头像
  String? userFaceURL;

  /// 发起入群申请的用户性别
  int? gender;

  /// 处理结果：-1：拒绝，1：同意
  int? handleResult;

  /// 请求说明
  String? reqMsg;

  /// 处理结果说明
  String? handledMsg;

  /// 请求时间
  int? reqTime;

  /// 处理者用户ID
  String? handleUserID;

  /// 处理时间
  int? handledTime;

  /// 扩展信息
  String? ex;

  /// 2：通过邀请  3：通过搜索  4：通过二维码
  int? joinSource;

  final ApplicationInfoType type;

  ApplicationInfo({
    required this.type,
    this.id,
    this.groupID,
    this.nickname,
    this.faceUrl,
    this.userFaceURL,
    this.gender,
    this.handleResult,
    this.reqMsg,
    this.handledMsg,
    this.reqTime,
    this.handleUserID,
    this.handledTime,
    this.ex,
    this.joinSource,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['nickname'] = nickname;
    data['faceUrl'] = faceUrl;
    data['userFaceURL'] = userFaceURL;
    data['gender'] = gender;
    data['handleResult'] = handleResult;
    data['reqMsg'] = reqMsg;
    data['handledMsg'] = handledMsg;
    data['reqTime'] = reqTime;
    data['handleUserID'] = handleUserID;
    data['handledTime'] = handledTime;
    data['ex'] = ex;
    data['joinSource'] = joinSource;
    return data;
  }

  /// 已同意
  bool get isAgreed => handleResult == 1;

  /// 已拒绝
  bool get isRejected => handleResult == -1;
}

// ignore_for_file: constant_identifier_names

abstract class MultiWindowRoutes {
  MultiWindowRoutes._();

  /// 图片
  static const PICTURE_PREVIEW = 'PICTURE_PREVIEW';

  /// 视频
  static const VIDEO_PREVIEW = 'VIDEO_PREVIEW';

  /// 聊天记录
  static const CHAT_RECORD = 'CHAT_RECORD';

  /// 历史消息
  static const HISTORY_MESSAGE = 'HISTORY_MESSAGE';
}
