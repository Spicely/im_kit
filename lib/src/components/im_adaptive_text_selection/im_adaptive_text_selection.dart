part of im_kit;

class ImAdaptiveTextSelection extends StatelessWidget {
  final TextSelectionToolbarAnchors anchors;

  const ImAdaptiveTextSelection({
    super.key,
    required this.anchors,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveTextSelectionToolbar(
      anchors: anchors,
      children: [
        GridItem(
          width: 50,
          height: 50,
          image: Icon(Icons.add),
          label: Text('111'),
          onTap: () {},
        )
      ],
    );
  }
}
