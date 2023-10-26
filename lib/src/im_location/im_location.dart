part of im_kit;

class ImLocation extends ImBase {
  const ImLocation({
    super.key,
    required super.isMe,
    required super.message,
    super.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap?.call(message);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 220,
          color: const Color.fromRGBO(247, 247, 247, 1),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            // des['name'] ?? '',
                            _fixAutoLines(message.ext.data?['name'] ?? ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF333333), fontWeight: FontWeight.w500),
                          ),
                          Text(
                            message.ext.data?['addr'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color.fromRGBO(175, 175, 175, 1)),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CachedImage(
                      imageUrl: message.ext.data?['url'] ?? '',
                      height: 90,
                      width: 220,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
