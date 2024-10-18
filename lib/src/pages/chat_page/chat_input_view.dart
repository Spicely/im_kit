part of '../../../im_kit.dart';

class ChatInputView extends StatelessWidget {
  final ChatPageController controller;

  const ChatInputView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: context.theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Visibility(
              visible: controller.attachments.isNotEmpty,
              child: Column(
                children: [
                  SizedBox(
                    height: 236,
                    child: Scrollbar(
                      controller: controller.scrollController,
                      child: ListView.separated(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 10);
                        },
                        itemBuilder: (BuildContext context, int index) => Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 190,
                              child: Column(
                                children: [
                                  CachedImage(
                                    file: controller.attachments[index].file,
                                    width: 170,
                                    height: 170,
                                    fit: BoxFit.cover,
                                    memory: controller.attachments[index].memory,
                                    circular: 5,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    basename(controller.attachments[index].file.path),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Tooltip(
                                      message: '剧透附件',
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton(
                                          style: IconButton.styleFrom(padding: const EdgeInsets.all(0)),
                                          icon: const Icon(Icons.remove_red_eye, size: 20),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: '修改附件',
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton(
                                          style: IconButton.styleFrom(padding: const EdgeInsets.all(0)),
                                          icon: const Icon(Icons.edit, size: 20),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ),
                                    Tooltip(
                                      message: '移除附件',
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton(
                                          style: IconButton.styleFrom(padding: const EdgeInsets.all(0)),
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          onPressed: () {
                                            controller.attachments.removeAt(index);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        itemCount: controller.attachments.length,
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // MenuAnchor(
                //   controller: controller.menuController,
                //   menuChildren: [
                //     const SizedBox(height: 5),
                //     MenuItemButton(
                //       leadingIcon: const Icon(Icons.upload_file_rounded),
                //       onPressed: controller.onSendFiles,
                //       child: const Text('上传文件'),
                //     ),
                //     MenuItemButton(
                //       leadingIcon: const Icon(Icons.apps),
                //       child: const Text('使用APP'),
                //       onPressed: () {},
                //     ),
                //     const SizedBox(height: 5),
                //   ],
                //   child: SizedBox(
                //     height: 60,
                //     child: Center(
                //       child: IconButton(
                //         icon: const Icon(Icons.add_circle),
                //         onPressed: controller.isCanSpeak ? controller.showFileSheet : null,
                //       ),
                //     ),
                //   ),
                // ),
                if (Utils.isMobile)
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: controller.isCanSpeak ? controller.showFileSheet : null,
                      ),
                    ),
                  ),
                Expanded(
                  child: KeyboardListener(
                    focusNode: controller.editFocusNode,
                    onKeyEvent: controller.onKeyEvent,
                    child: Stack(
                      children: [
                        Obx(
                          () => ExtendedTextField(
                            maxLines: null,
                            focusNode: controller.focusNode,
                            controller: controller.textEditingController,
                            readOnly: !controller.isCanSpeak,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              labelStyle: TextStyle(fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
                              hintText: '消息',
                              hintStyle: TextStyle(fontSize: 14),
                              filled: true,
                              isCollapsed: true,
                              fillColor: Colors.transparent,
                            ),
                            specialTextSpanBuilder: ImExtendTextBuilder(
                              allAtMap: controller.atUserMap,
                            ),
                            // extendedContextMenuBuilder: (BuildContext context, ExtendedEditableTextState editableTextState) => EditActions(editableTextState: editableTextState),
                          ),
                        ),
                        Obx(
                          () => controller.isCanSpeak
                              ? const SizedBox()
                              : Center(
                                  child: Text(controller.isMute.value ? '全体禁言中' : '你已被禁言', style: const TextStyle(fontSize: 12, color: Color.fromRGBO(193, 193, 193, 1))),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                MenuAnchor(
                  alignmentOffset: const Offset(-450, 10),
                  controller: controller.emojiMenuController,
                  menuChildren: [],
                  // menuChildren: [EmojiDialogView(controller: controller)],
                  child: SizedBox(
                    height: 45,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          if (controller.emojiMenuController.isOpen) {
                            controller.emojiMenuController.close();
                          } else {
                            controller.emojiMenuController.open();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.folder),
                      onPressed: controller.onSendFiles,
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: controller.onSendMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Obx(
          //   () => controller.quoteMessage.value == null
          //       ? const SizedBox()
          //       : Row(
          //           children: [
          //             Container(
          //               margin: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 5),
          //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //               decoration: BoxDecoration(
          //                 color: const Color(0xFFE5E5E5),
          //                 borderRadius: BorderRadius.circular(5),
          //               ),
          //               constraints: const BoxConstraints(maxWidth: 400),
          //               child: Text.rich(
          //                 controller.quoteMessage.value!.m.type,
          //                 style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
          //                 maxLines: 2,
          //                 overflow: TextOverflow.ellipsis,
          //               ),
          //             ),
          //             IconButton(
          //               style: ButtonStyle(
          //                 backgroundColor: ButtonState.resolveWith((states) => states.isHovering ? Theme.of(context).primaryColor : const Color(0xFFE5E5E5)),
          //                 shape: ButtonState.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          //               ),
          //               icon: const Icon(FluentIcons.chrome_close, size: 8),
          //               onPressed: () {
          //                 controller.quoteMessage.value = null;
          //               },
          //             ),
          //           ],
          //         ),
          // ),
        ],
      ),
    );
  }
}
