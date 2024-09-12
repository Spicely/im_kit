part of im_kit;

const double _kToolbarScreenPadding = 8.0;
const double _kToolbarWidth = 90.0;

class ChatActions extends StatelessWidget {
  final MessageExt extMsg;

  final ChatPageController controller;

  final SelectableRegionState selectableRegionState;

  const ChatActions({
    super.key,
    required this.extMsg,
    required this.controller,
    required this.selectableRegionState,
  });

  @override
  Widget build(BuildContext context) {
    final double paddingAbove = MediaQuery.paddingOf(context).top + _kToolbarScreenPadding;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);
    Offset anchor;
    anchor = selectableRegionState.contextMenuAnchors.primaryAnchor - localAdjustment;
    return CustomSingleChildLayout(
      delegate: DesktopTextSelectionToolbarLayoutDelegate(anchor: anchor),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(5),
        child: SizedBox(
          width: _kToolbarWidth,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListItem(
                height: 35,
                title: const Text('复制', style: TextStyle(fontSize: 12)),
                onTap: () {
                  if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType)) {
                    controller.copyFileToClipboard(extMsg);
                  } else {
                    String text = ImKitIsolateManager._copyText.isEmpty ? extMsg.m.atTextElem?.text ?? extMsg.m.textElem?.content ?? '' : ImKitIsolateManager._copyText;
                    controller.copyText(text);
                  }
                  FocusScopeNode currentFocus = FocusScope.of(Get.context!);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
              ListItem(
                height: 35,
                title: const Text('转发', style: TextStyle(fontSize: 12)),
                onTap: () {
                  controller.selectList.clear();
                  controller.selectList.add(extMsg);
                  controller.onForward();
                },
              ),
              ListItem(
                height: 35,
                title: const Text('回复', style: TextStyle(fontSize: 12)),
                onTap: () {
                  controller.quoteMessage.value = extMsg;
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
              if ([MessageType.file, MessageType.video].contains(extMsg.m.contentType))
                ListItem(
                  height: 35,
                  title: const Text('另存为', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    if (extMsg.ext.file != null) {
                      controller.saveFile(extMsg);
                    } else {
                      FocusScopeNode currentFocus = FocusScope.of(Get.context!);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      // OpenIM.iMManager.messageManager.downloadFileReturnPaths(message: extMsg.m).then((value) {
                      //   if (value.length == 2) {
                      //     extMsg.ext.previewFile = File(value.first);
                      //     extMsg.ext.file = File(value.last);
                      //   } else {
                      //     extMsg.ext.file = File(value.first);
                      //   }
                      //   controller.saveFile(extMsg, onSuccess: () {
                      //     controller.showToast(title: '保存成功', severity: InfoBarSeverity.success);
                      //   });
                      // });
                    }
                  },
                ),
              ListItem(
                height: 35,
                title: const Text('多选', style: TextStyle(fontSize: 12)),
                onTap: () {
                  controller.setMultiSelect();
                },
              ),
              if (extMsg.m.sendID == OpenIM.iMManager.uid)
                ListItem(
                  height: 35,
                  title: const Text('撤回', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    controller.revokeMessage(extMsg);
                  },
                ),
              if (extMsg.m.contentType == MessageType.picture && extMsg.ext.file != null)
                ListItem(
                  height: 35,
                  title: const Text('另存为', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    controller.saveFile(extMsg);
                  },
                ),
              ListItem(
                height: 35,
                title: const Text('删除', style: TextStyle(fontSize: 12)),
                onTap: () {
                  controller.deleteMessage(extMsg, onSuccess: () {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // /// 渲染桌面端
  // Widget _buildDesktop(BuildContext context) {
  //   return u.MenuFlyout(
  //     items: [
  //       if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType))
  //         u.MenuFlyoutItem(
  //           text: const Text('复制', style: TextStyle(fontSize: 12)),
  //           onPressed: () {},
  //         ),
  //       u.MenuFlyoutItem(
  //         text: const Text('转发', style: TextStyle(fontSize: 12)),
  //         onPressed: () {
  //           controller.selectList.clear();
  //           controller.selectList.add(extMsg);
  //           controller.onForward();
  //         },
  //       ),
  //       u.MenuFlyoutItem(
  //         text: const Text('回复', style: TextStyle(fontSize: 12)),
  //         onPressed: () {
  //           controller.quoteMessage.value = extMsg;
  //           FocusScopeNode currentFocus = FocusScope.of(context);
  //           if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
  //             FocusManager.instance.primaryFocus?.unfocus();
  //           }
  //         },
  //       ),
  //       if ([MessageType.file, MessageType.video, MessageType.picture].contains(extMsg.m.contentType))
  //         u.MenuFlyoutItem(
  //           text: const Text('另存为', style: TextStyle(fontSize: 12)),
  //           onPressed: () {
  //             if (extMsg.ext.file != null) {
  //               controller.saveFile(extMsg);
  //             } else {
  //               FocusScopeNode currentFocus = FocusScope.of(Get.context!);
  //               if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
  //                 FocusManager.instance.primaryFocus?.unfocus();
  //               }
  //               // OpenIM.iMManager.messageManager.downloadFileReturnPaths(message: extMsg.m).then((value) {
  //               //   if (value.length == 2) {
  //               //     extMsg.ext.previewFile = File(value.first);
  //               //     extMsg.ext.file = File(value.last);
  //               //   } else {
  //               //     extMsg.ext.file = File(value.first);
  //               //   }
  //               //   controller.saveFile(extMsg, onSuccess: () {
  //               //     controller.showToast(title: '保存成功', severity: InfoBarSeverity.success);
  //               //   });
  //               // });
  //             }
  //           },
  //         ),
  //       u.MenuFlyoutItem(
  //         text: const Text('多选', style: TextStyle(fontSize: 12)),
  //         onPressed: () {
  //           controller.setMultiSelect();
  //         },
  //       ),
  //       if (extMsg.m.sendID == OpenIM.iMManager.uid)
  //         u.MenuFlyoutItem(
  //           text: const Text('撤回', style: TextStyle(fontSize: 12)),
  //           onPressed: () {
  //             controller.revokeMessage(extMsg);
  //           },
  //         ),
  //       u.MenuFlyoutItem(
  //         text: const Text('删除', style: TextStyle(fontSize: 12)),
  //         onPressed: () {
  //           controller.deleteMessage(extMsg, onSuccess: () {});
  //         },
  //       ),
  //     ],
  //   );
  // }
}
