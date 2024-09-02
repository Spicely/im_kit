// part of im_kit;

// enum GroupActionType {
//   /// 权限设置
//   permissions,

//   /// 禁言列表
//   bankList,
// }

// class GroupActions extends StatelessWidget {
//   final GroupMembersInfo userInfo;

//   final ChatController controller;

//   final GroupActionType type;

//   const GroupActions({
//     super.key,
//     required this.userInfo,
//     required this.controller,
//     required this.type,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MenuFlyout(items: buildTypeList());
//   }

//   List<MenuFlyoutItem> buildTypeList() {
//     return switch (type) {
//       GroupActionType.permissions => [
//           if (userInfo.roleLevel != GroupRoleLevel.admin)
//             MenuFlyoutItem(
//               text: const Text('设置为管理员', style: TextStyle(fontSize: 12)),
//               onPressed: () {
//                 controller.setGroupMemberRoleLevel(
//                   roleLevel: GroupRoleLevel.admin,
//                   userID: userInfo.userID!,
//                   onSuccess: () {
//                     controller.showToast(title: '修改成功');
//                   },
//                 );
//               },
//             ),
//           if (userInfo.roleLevel == GroupRoleLevel.admin)
//             MenuFlyoutItem(
//               text: const Text('撤销管理员', style: TextStyle(fontSize: 12)),
//               onPressed: () {
//                 controller.setGroupMemberRoleLevel(
//                   roleLevel: GroupRoleLevel.member,
//                   userID: userInfo.userID!,
//                   onSuccess: () {
//                     controller.showToast(title: '修改成功');
//                   },
//                 );
//               },
//             ),
//           if (controller.isOwner)
//             MenuFlyoutItem(
//               text: const Text('转让群', style: TextStyle(fontSize: 12)),
//               onPressed: () {
//                 Get.back();
//                 controller.showConfirmDialog(
//                   title: '确认转让群？',
//                   content: '转让后不可撤销',
//                   onConfirm: () {
//                     controller.transferGroupOwner(
//                       userInfo.userID!,
//                       onSuccess: () {
//                         Get.back();
//                         controller.showToast(title: '转让成功');
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//         ],
//       GroupActionType.bankList => [
//           if (userInfo.muteEndTime == 0)
//             MenuFlyoutItem(
//               text: const Text('禁言', style: TextStyle(fontSize: 12)),
//               onPressed: () {
//                 controller.setGroupMemberMute(
//                   seconds: 999999999,
//                   userID: userInfo.userID!,
//                   onSuccess: () {
//                     controller.showToast(title: '修改成功');
//                   },
//                 );
//               },
//             ),
//           if (userInfo.muteEndTime != 0)
//             MenuFlyoutItem(
//               text: const Text('解除禁言', style: TextStyle(fontSize: 12)),
//               onPressed: () {
//                 controller.setGroupMemberMute(
//                   seconds: 0,
//                   userID: userInfo.userID!,
//                   onSuccess: () {
//                     controller.showToast(title: '修改成功');
//                   },
//                 );
//               },
//             ),
//         ],
//     };
//   }
// }
