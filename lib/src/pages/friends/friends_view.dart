part of im_kit;

class FriendsView extends StatelessWidget {
  final void Function()? onNewFriendTap;

  const FriendsView({
    super.key,
    this.onNewFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FriendsViewController(),
      builder: (controller) => Scaffold(
        body: Column(
          children: [
            SizedBox(height: WindowBar.barHeight),
            ListItem(
              title: const Text('新朋友'),
              value: Obx(
                () => Badge.count(
                  count: controller.imController.applicationCount.value,
                  isLabelVisible: controller.imController.applicationCount.value != 0,
                ),
              ),
              onTap: onNewFriendTap,
              showArrow: true,
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CachedImage(
                        imageUrl: controller.imController.friends[index].faceURL,
                        width: 40,
                        height: 40,
                        circular: 40,
                      ),
                      title: Text(controller.imController.friends[index].nickname),
                    );
                  },
                  itemCount: controller.imController.friends.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
