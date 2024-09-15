part of im_kit;

class ChatMoreActions extends StatelessWidget {
  final ChatControllerMixin controller;

  const ChatMoreActions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (Utils.isDesktop) {
      return MenuAnchor(
        controller: controller.menuController,
        menuChildren: [
          const SizedBox(height: 2),
          MenuItemButton(
            leadingIcon: const Icon(Icons.close_outlined),
            onPressed: controller.deleteConversationAndDeleteAllMsg,
            child: const Text('删除会话消息'),
          ),
          if (controller.isFriend)
            MenuItemButton(
              leadingIcon: const Icon(Icons.person_off, color: Colors.red),
              onPressed: controller.deleteFriend,
              child: const Text('解除好友', style: TextStyle(color: Colors.red)),
            ),
          if (controller.isOwner)
            MenuItemButton(
              leadingIcon: const Icon(Icons.person_off, color: Colors.red),
              onPressed: controller.deleteFriend,
              child: const Text('解散群聊', style: TextStyle(color: Colors.red)),
            ),
          if (controller.isMember || controller.isCanAdmin)
            MenuItemButton(
              leadingIcon: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
              onPressed: controller.quitGroup,
              child: const Text('退出群聊', style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 2),
        ],
        child: IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {
            if (!controller.menuController.isOpen) {
              controller.menuController.open();
            } else {
              controller.menuController.close();
            }
          },
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.more_vert_rounded),
      onPressed: () {},
    );
  }
}
