part of im_kit;

// class ImAdaptiveTextItem {
//   final String label;
//
//   final Widget icon;
//
//   final Function() onPressed;
//
//   ImAdaptiveTextItem({
//     required this.label,
//     required this.icon,
//     required this.onPressed,
//   });
// }
//
// class ImAdaptiveTextSelection extends StatelessWidget {
//   final TextSelectionToolbarAnchors anchors;
//   Size arrowSize=const Size(14.0, 7.0);///箭头尺寸
//   double itemH=73;///单个菜单的高度
//   double itemW=50;///单个菜单宽度
//   Color bgColor= Color.fromRGBO(10, 41, 62, 1);///背景颜色
//   final List<ImAdaptiveTextItem> children;
//
//   double get mh {
//     if(children.length>5){
//       return itemH*2;
//     }
//     return itemH;
//   }
//
//   ImAdaptiveTextSelection({
//     super.key,
//     required this.anchors,
//     required this.children,
//   });
//
//
//   Widget toolbarBuilder(BuildContext context, Offset anchor, bool isAbove, Widget child) {
//     final Widget outputChild = _CupertinoTextSelectionToolbarShape(
//       anchor: anchor,
//       isAbove: isAbove,
//       child:Container(
//         color:bgColor,
//         padding: EdgeInsets.only(top:arrowSize.height),
//         child: child,
//       ),
//       mh:mh+arrowSize.height,
//       kToolbarArrowSize :arrowSize,
//     );
//     // return outputChild;
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.all(Radius.zero),
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: CupertinoColors.black.withOpacity(0.1),
//             blurRadius: 15.0,
//             offset: Offset( 0.0,isAbove ? 0.0 :arrowSize.height),
//           ),
//         ],
//       ),
//       child: outputChild,
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var bl=anchors.secondaryAnchor == null? anchors.primaryAnchor : anchors.secondaryAnchor!;
//     // Incorporate the padding distance between the content and toolbar.
//     final Offset anchorAbovePadded = anchors.primaryAnchor - const Offset(0.0, 8.0);
//     final Offset anchorBelowPadded = bl + const Offset(0.0, 14.0);
//     const double screenPadding = 44;
//     final double paddingAbove = MediaQuery.paddingOf(context).top + screenPadding;
//     final double availableHeight = anchorAbovePadded.dy - 8.0 - paddingAbove;
//     final bool fitsAbove = mh <= availableHeight;
//     final Offset localAdjustment = Offset(screenPadding, paddingAbove);
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         screenPadding,
//         paddingAbove,
//         screenPadding,
//         screenPadding,
//       ),
//       child: CustomSingleChildLayout(
//         delegate: TextSelectionToolbarLayoutDelegate(
//           anchorAbove: anchorAbovePadded - localAdjustment,
//           anchorBelow: anchorBelowPadded - localAdjustment,
//           fitsAbove: fitsAbove,
//         ),
//         child:toolbarBuilder(
//           context,anchorAbovePadded,fitsAbove,
//           Container(
//             clipBehavior:Clip.hardEdge,
//             padding: EdgeInsets.only(left:5,right:5),
//             decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(5)
//             ),
//             child: Wrap(
//                 children: children.map((e) {
//                   return GestureDetector(
//                     onTap: e.onPressed,
//                     child: Container(
//                       width: itemW,
//                       height: itemH,
//                       // color: bgColor,
//                       // padding: const EdgeInsets.symmetric(vertical: 12),///24+20+2+
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           e.icon,
//                           Container(
//                             margin: const EdgeInsets.only(top: 5),
//                             child: Text(
//                               e.label,
//                               style: const TextStyle(color: Colors.white, fontSize: 12),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList()),
//           ),
//         ),
//       ),
//     );
//   }
// }

