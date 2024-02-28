part of im_kit;

class ImRedEnv extends ImBase {
  const ImRedEnv({
    super.key,
    required super.isMe,
    required super.message,
    required super.showSelect,
  });

  @override
  Widget build(BuildContext context) {
    ImAvatarTheme avatarTheme = ImKitTheme.of(context).chatTheme.avatarTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedImage(
          imageUrl: message.m.senderFaceUrl,
          width: avatarTheme.width,
          height: avatarTheme.height,
          circular: avatarTheme.circular,
          fit: avatarTheme.fit,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.m.isGroupChat && !isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(message.m.senderNickname ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // onTap?.call(message);
                          },
                          onDoubleTap: () {
                            // onDoubleTap?.call(message);
                          },
                          child: Directionality(
                            textDirection: isMe ? TextDirection.ltr : TextDirection.ltr,
                            child: Container(
                                width: 250,
                                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: isMe ? const AssetImage('assets/icons/redenvelopebg.png', package: 'im_kit') : const AssetImage('assets/icons/redenvelopebglf.png', package: 'im_kit'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 0.01, width: double.infinity),
                                    Row(
                                      children: [
                                        Image.asset('assets/icons/redenvelope.png', package: 'im_kit', width: 36),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message.ext.data['title'],
                                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(height: 0.7, thickness: 0.7, color: Colors.white.withOpacity(0.3)),
                                    const SizedBox(height: 4),
                                    Text("MOYO红包", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)))
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // SizedBox(child: getStatusWidget()),
            ],
          ),
        ),
      ],
    );
  }
}
