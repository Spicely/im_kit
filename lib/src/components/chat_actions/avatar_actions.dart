// part of im_kit;

// class AvatarActions extends StatelessWidget {
//   final ChatController controller;

//   final FullUserInfo userInfo;

//   const AvatarActions({
//     super.key,
//     required this.controller,
//     required this.userInfo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MenuFlyout(
//       items: [
//         // if (userInfo.isFriendship!)
//         //   MenuFlyoutItem(
//         //     text: const Text('发送消息', style: TextStyle(fontSize: 12)),
//         //     onPressed: () {
//         //       Utils.exceptionCapture(() async {
//         //         Get.back();
//         //         ConversationInfo conversationInfo = await OpenIM.iMManager.conversationManager.getOneConversation(sourceID: userInfo.userID!, sessionType: ConversationType.single);
//         //         HomeController homeController = Get.find<HomeController>();
//         //         homeController.paneType.value = PaneType.chat;
//         //         homeController.selected.value = 0;
//         //         homeController.toChatPage(conversationInfo);
//         //       });
//         //     },
//         //   ),
//         MenuFlyoutItem(
//           text: const Text('@ TA', style: TextStyle(fontSize: 12)),
//           onPressed: () {
//             Get.back();
//             controller.editFocusNode.requestFocus();
//             GroupMembersInfo? groupInfo = controller.groupMembers.firstWhereOrNull((v) => v.userID == userInfo.userID);
//             Future.delayed(const Duration(milliseconds: 100), () {
//               if (groupInfo != null) {
//                 int index = controller.textEditingController.selection.baseOffset;

//                 String atText = '';
//                 controller.atUserMap.add(AtUserInfo(atUserID: groupInfo.groupID, groupNickname: groupInfo.nickname));

//                 /// 增加@用户名
//                 atText += '@${groupInfo.userID} ';

//                 /// 从光标位置开始插入
//                 String text = controller.textEditingController.text;
//                 text = text.substring(0, index) + atText + text.substring(index, text.length);
//                 controller.textEditingController.text = text;
//                 controller.editFocusNode.requestFocus();
//               }
//             });
//           },
//         ),
//       ],
//     );
//   }
// }
