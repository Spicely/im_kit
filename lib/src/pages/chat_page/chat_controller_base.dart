part of '../../../im_kit.dart';

abstract class ChatControllerBase {
  /// 初始化
  void init();

  /// 从本地和服务器删除指定会话及会话中的消息
  void deleteConversationAndDeleteAllMsg();

  /// 删除好友
  void deleteFriend();

  /// 退出群聊
  void quitGroup();
}

mixin ChatControllerMixin implements ChatControllerBase {
  late Rx<ConversationInfo?> conversationInfo;

  final MenuController menuController = MenuController();

  late RxList<MessageExt> data;

  final IMController imController = Get.find<IMController>();

  /// 聊天对象id
  String? get userID => conversationInfo.value?.userID;

  String? get groupID => conversationInfo.value?.groupID;

  /// 是单聊
  bool get isSingleChat => conversationInfo.value?.isSingleChat ?? false;

  /// 是群聊
  bool get isGroupChat => conversationInfo.value?.isGroupChat ?? false;

  /// 自己在群里的信息
  GroupMembersInfo? get gInfo => (isGroupChat && groupMembers.isNotEmpty) ? groupMembers.firstWhere((v) => v.userID == uInfo.userID) : null;

  /// 是否是管理员
  bool get isAdmin => gInfo?.roleLevel == GroupRoleLevel.admin;

  /// 是否是群成员
  bool get isMember => gInfo?.roleLevel == GroupRoleLevel.member;

  /// 是否是群主
  bool get isOwner => gInfo?.roleLevel == GroupRoleLevel.owner;

  /// 群成员信息
  RxList<GroupMembersInfo> groupMembers = RxList([]);

  /// 群信息
  Rx<GroupInfo?> groupInfo = Rx(null);

  /// 自己的信息
  UserInfo get uInfo => OpenIM.iMManager.uInfo!;

  /// 私聊用户信息
  Rx<FullUserInfo?> chatUserInfo = Rx(null);

  /// 是否能管理群
  bool get isCanAdmin => isGroupChat && gInfo?.roleLevel != GroupRoleLevel.member;

  /// 是否个人禁言
  RxBool isMuteUser = false.obs;

  /// 是否能发言
  bool get isCanSpeak => !isMuteUser.value || !isMute.value || isCanAdmin;

  /// 是否全体禁言
  RxBool isMute = false.obs;

  /// 不允许通过群获取成员资料
  bool get lookMemberInfo => isSingleChat ? false : groupInfo.value?.lookMemberInfo == 1;

  /// 群id
  String? get gId => Utils.getValue<String?>(conversationInfo.value?.groupID, null);

  /// 用户id
  String? get uId => Utils.getValue<String?>(conversationInfo.value?.userID, null);

  /// 是否为好友
  bool get isFriend => imController.friends.any((v) => v.userID == uId);

  @override
  void deleteConversationAndDeleteAllMsg() {
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.deleteConversationAndDeleteAllMsg(conversationID: conversationInfo.value?.conversationID ?? '');
      data.clear();
    });
  }

  /// 删除好友
  @override
  void deleteFriend() {
    if (conversationInfo.value == null || !isSingleChat) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.conversationManager.deleteConversationAndDeleteAllMsg(conversationID: conversationInfo.value?.conversationID ?? '');
      await OpenIM.iMManager.friendshipManager.deleteFriend(userID: uId!);
      imController.friends.removeWhere((v) => v.userID == uId);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value?.conversationID ?? '');
    });
  }

  /// 退出群聊
  @override
  void quitGroup() {
    if (gId == null) return;
    Utils.exceptionCapture(() async {
      await OpenIM.iMManager.groupManager.quitGroup(gid: gId!);
      await OpenIM.iMManager.conversationManager.deleteConversation(conversationID: conversationInfo.value!.conversationID);
    });
  }

  @override
  void init() {}
}
