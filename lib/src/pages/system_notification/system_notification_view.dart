part of im_kit;

class SystemNotificationView extends StatelessWidget {
  final SystemNotificationController controller;

  const SystemNotificationView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: controller.conversationInfo.value.conversationID,
      init: controller,
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(controller.conversationInfo.value.showName ?? '')),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          controller: controller.scrollController,
          children: [
            Obx(
              () => ListView.builder(
                itemCount: controller.data.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(controller.data[index].ext.time, style: const TextStyle(fontSize: 10)),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: const Color.fromRGBO(24, 24, 24, 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.data[index].ext.data?['notificationName'] ?? '',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.data[index].ext.data?['text'] ?? '',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
