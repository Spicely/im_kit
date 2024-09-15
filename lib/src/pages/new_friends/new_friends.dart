part of im_kit;

class NewFriends extends StatelessWidget {
  const NewFriends({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: NewFriendsController(),
      builder: (controller) => Scaffold(
          body: Column(
        children: [
          SizedBox(height: WindowBar.barHeight),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      leading: CachedImage(
                        imageUrl: controller.imController.applicationList[index].faceUrl,
                        width: 40,
                        height: 40,
                        circular: 40,
                      ),
                      title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: controller.imController.applicationList[index].nickname ?? ''),
                            TextSpan(text: '    来源：${controller.imController.applicationList[index].joinSource ?? '查找'}', style: TextStyle(color: context.theme.disabledColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      subtitle: Text(Utils.getValue(controller.imController.applicationList[index].reqMsg, '申请加我为好友')),
                      trailing: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: [
                          if (controller.imController.applicationList[index].handleResult == 0)
                            ElevatedButton(
                              onPressed: () {
                                controller.imController.agreeFriendApplication(controller.imController.applicationList[index]);
                              },
                              child: const Text('同意'),
                            ),
                          if (controller.imController.applicationList[index].handleResult == 0)
                            OutlinedButton(
                              onPressed: () {
                                controller.imController.rejectFriendApplication(controller.imController.applicationList[index]);
                              },
                              child: const Text('拒绝'),
                            ),
                          if (controller.imController.applicationList[index].isAgreed) Text('已同意', style: TextStyle(color: context.theme.disabledColor)),
                          if (controller.imController.applicationList[index].isRejected) Text('已拒绝', style: TextStyle(color: context.theme.disabledColor)),
                        ],
                      ));
                },
                itemCount: controller.imController.applicationList.length,
              ),
            ),
          ),
        ],
      )),
    );
  }
}
