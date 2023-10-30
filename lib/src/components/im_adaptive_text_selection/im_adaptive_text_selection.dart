part of im_kit;

class ImAdaptiveTextItem {
  final String label;

  final Widget icon;

  final Function() onPressed;

  ImAdaptiveTextItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

class ImAdaptiveTextSelection extends StatelessWidget {
  final TextSelectionToolbarAnchors anchors;

  final List<ImAdaptiveTextItem> children;

  const ImAdaptiveTextSelection({
    super.key,
    required this.anchors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Incorporate the padding distance between the content and toolbar.
    final Offset anchorAbovePadded = anchors.primaryAnchor - const Offset(0.0, 8.0);
    final Offset anchorBelowPadded = anchors.primaryAnchor + const Offset(0.0, 2.0);

    const double screenPadding = CupertinoTextSelectionToolbar.kToolbarScreenPadding;
    final double paddingAbove = MediaQuery.paddingOf(context).top + screenPadding;
    final double availableHeight = anchorAbovePadded.dy - 2.0 - paddingAbove;
    final bool fitsAbove = 44.0 <= availableHeight;
    // Makes up for the Padding above the Stack.
    final Offset localAdjustment = Offset(screenPadding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenPadding,
        paddingAbove,
        screenPadding,
        screenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove: anchorAbovePadded - localAdjustment,
          anchorBelow: anchorBelowPadded - localAdjustment,
          fitsAbove: fitsAbove,
        ),
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
          clipBehavior: Clip.antiAlias,
          elevation: 1.0,
          type: MaterialType.card,
          child: Wrap(
              children: children.map((e) {
            return Container(
              width: 280 / 5,
              color: const Color.fromRGBO(10, 41, 62, 1),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  e.icon,
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Text(
                      e.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ),
      ),
    );
  }
}
