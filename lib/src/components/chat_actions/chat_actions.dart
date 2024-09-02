part of im_kit;

const double _kToolbarScreenPadding = 8.0;
const double _kToolbarWidth = 90.0;

class ChatActions extends StatelessWidget {
  final MessageExt extMsg;

  final ChatPageController controller;

  final SelectableRegionState? selectableRegionState;
  final Offset? position;

  const ChatActions({
    super.key,
    required this.extMsg,
    required this.controller,
    this.selectableRegionState,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    if (position != null) {
      return _buildDesktop(context);
    } else {
      return _buildMobile(context);
    }
  }

  /// 渲染桌面端
  Widget _buildDesktop(BuildContext context) {
    return u.MenuFlyout(
      items: [
        if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType))
          u.MenuFlyoutItem(
            text: const Text('复制', style: TextStyle(fontSize: 12)),
            onPressed: () {
              controller.copyFileToClipboard(extMsg);
            },
          ),
        u.MenuFlyoutItem(
          text: const Text('转发', style: TextStyle(fontSize: 12)),
          onPressed: () {
            controller.selectList.clear();
            controller.selectList.add(extMsg);
            controller.onForward();
          },
        ),
        u.MenuFlyoutItem(
          text: const Text('回复', style: TextStyle(fontSize: 12)),
          onPressed: () {
            controller.quoteMessage.value = extMsg;
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
        ),
        if ([MessageType.file, MessageType.video, MessageType.picture].contains(extMsg.m.contentType))
          u.MenuFlyoutItem(
            text: const Text('另存为', style: TextStyle(fontSize: 12)),
            onPressed: () {
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
        u.MenuFlyoutItem(
          text: const Text('多选', style: TextStyle(fontSize: 12)),
          onPressed: () {
            controller.setMultiSelect();
          },
        ),
        if (extMsg.m.sendID == OpenIM.iMManager.uid)
          u.MenuFlyoutItem(
            text: const Text('撤回', style: TextStyle(fontSize: 12)),
            onPressed: () {
              controller.revokeMessage(extMsg);
            },
          ),
        u.MenuFlyoutItem(
          text: const Text('删除', style: TextStyle(fontSize: 12)),
          onPressed: () {
            controller.deleteMessage(extMsg, onSuccess: () {});
          },
        ),
      ],
    );
  }

  /// 渲染移动端
  Widget _buildMobile(BuildContext context) {
    final double paddingAbove = MediaQuery.paddingOf(context).top + _kToolbarScreenPadding;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);
    Offset anchor;
    if (selectableRegionState != null) {
      anchor = selectableRegionState!.contextMenuAnchors.primaryAnchor - localAdjustment;
    } else {
      anchor = Offset.zero;
    }
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
              if ([MessageType.text, MessageType.atText, MessageType.advancedText, MessageType.quote].contains(extMsg.m.contentType))
                ListItem(
                  height: 35,
                  title: const Text('复制', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    selectableRegionState?.copySelection(SelectionChangedCause.toolbar);
                    // /// 获取选中的文本
                    // String text = selectableRegionState.widget.controller.text;
                    // int start = selectableRegionState.widget.controller.selection.start;
                    // int end = editableTextState.widget.controller.selection.end;
                    // if (start - end != 0) {
                    //   text = text.substring(start, end);
                    // }

                    // /// 移除text中的\u{200B}
                    // text = text.replaceAll('\u{200B}', '');
                    // if (text.isEmpty) {
                    //   text = extMsg.m.atTextElem?.text ?? extMsg.m.textElem?.content ?? '';
                    // }
                    // controller.copyText(text);
                    // FocusScopeNode currentFocus = FocusScope.of(context);
                    // if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    //   FocusManager.instance.primaryFocus?.unfocus();
                    // }

                    // /// 让文本失去焦点
                    // editableTextState.widget.controller.selection = const TextSelection.collapsed(offset: 0);
                  },
                ),
              if ([MessageType.file, MessageType.picture, MessageType.video, MessageType.voice].contains(extMsg.m.contentType))
                ListItem(
                  height: 35,
                  title: const Text('复制', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    controller.copyFileToClipboard(extMsg);
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
}
